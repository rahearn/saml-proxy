require "rails_helper"

RSpec.describe "SamlIdps", type: :request do
  include OidcClient

  let(:saml_settings) do
    OneLogin::RubySaml::Settings.new.tap do |settings|
      settings.sp_entity_id = "RSpec"
      settings.assertion_consumer_service_url = "http://localhost/saml/callback"
      settings.idp_sso_service_url = "http://localhost/saml/auth"
    end
  end
  let(:auth_request) { OneLogin::RubySaml::Authrequest.new }

  let(:uaa) {
    {
      "cloud-gov-identity-provider": [{
        credentials: {
          client_id: "client-id",
          client_secret: "client-secret"
        }
      }]
    }
  }
  around do |example|
    ClimateControl.modify VCAP_SERVICES: uaa.to_json do
      example.run
    end
  end

  describe "GET /saml/metadata" do
    it "returns the xml metadata" do
      get "/saml/metadata"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /saml/auth" do
    it "redirects to uaa" do
      get auth_request.create(saml_settings)
      expect(response).to redirect_to(oidc_client.authorization_uri(state: session[:state]))
    end
  end

  describe "GET /oidc/callback" do
    before(:each) {
      get auth_request.create(saml_settings)
    }
    let(:state) { session[:state] }

    context "no JWT" do
      it "returns :forbidden" do
        expect_any_instance_of(OpenIDConnect::Client).to receive(:access_token!).and_return nil
        get "/oidc/callback", params: {state: state, code: "feedabee"}
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "mismatched state" do
      it "returns :forbidden" do
        get "/oidc/callback", params: {state: "incorrect"}
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "valid JWT (pretend, anyway)" do
      let(:user_fields) {
        {
          email: "feedabee@gsa.gov",
          user_name: "feedabee@gsa.gov",
          user_id: "6fa1a182-256a-4c03-8226-db16902e1b22"
        }.with_indifferent_access
      }
      let(:access_token) { double }
      let(:user) { User.new user_fields }
      it "returns an auto-submitting form" do
        expect_any_instance_of(OpenIDConnect::Client).to receive(:access_token!).and_return access_token
        expect(User).to receive(:from_token).with(access_token).and_return user
        get "/oidc/callback", params: {state: state, code: "feedabee"}
        expect(response).to have_http_status(:success)
      end
    end
  end
end
