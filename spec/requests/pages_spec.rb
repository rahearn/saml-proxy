require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "redirects to GDG" do
      allow(Rails.env).to receive(:production?).and_return true
      get "/"
      expect(response).to redirect_to("https://gsa.gitlab-dedicated.us")
    end
  end
end
