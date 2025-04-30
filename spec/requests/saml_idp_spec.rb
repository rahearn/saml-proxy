require "rails_helper"

RSpec.describe "SamlIdps", type: :request do
  describe "GET /saml/metadata" do
    it "returns the xml metadata" do
      get "/saml/metadata"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /saml/auth" do
    it "redirects to uaa" do
      pending "needs a properly formed saml request to work"
      get "/saml/auth"
      expect(response).to redirect_to("https://login.fr.cloud.gov/oauth/authorize")
    end
  end
end
