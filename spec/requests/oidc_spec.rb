require "rails_helper"

RSpec.describe "Oidcs", type: :request do
  let(:client) { double OpenIDConnect::Client }
  before(:each) {
    allow(OpenIDConnect::Client).to receive(:new).and_return client
  }
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

  describe "GET /callback" do
    it "returns http success", :vcr do
      expect(client).to receive(:authorization_code=).with("auth-code")
      expect(client).to receive(:access_token!).and_return(double(id_token: "feedabee"))
      get "/oidc/callback", params: {code: "auth-code"}
      expect(response).to have_http_status(:success)
    end
  end
end
