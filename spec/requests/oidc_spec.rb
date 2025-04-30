require "rails_helper"

RSpec.describe "Oidcs", type: :request do
  let(:client) { double OpenIDConnect::Client }
  let(:credentials) { {client_id: "client-id", client_secret: "client-secret"} }

  describe "GET /callback" do
    it "returns http success", :vcr do
      allow(OpenIDConnect::Client).to receive(:new).and_return client
      allow(CloudGovConfig).to receive(:dig).with("cloud-gov-identity-provider", "credentials").and_return credentials
      expect(client).to receive(:authorization_code=).with("auth-code")
      expect(client).to receive(:access_token!).and_return(double(id_token: ""))
      allow(JWT).to receive(:decode).and_return [double, double]
      get "/oidc/callback", params: {code: "auth-code"}
      expect(response).to have_http_status(:success)
    end
  end
end
