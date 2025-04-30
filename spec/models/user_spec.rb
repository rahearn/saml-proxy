# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:user_fields) {
    {
      user_name: "User Name",
      user_id: "ce3f063b-1804-45a1-892e-c8b60589dae4",
      email: "example@gsa.gov"
    }.with_indifferent_access
  }
  subject { described_class.new user_fields }

  describe ".from_token", :vcr do
    context "valid JWT" do
      before(:each) { allow(JWT).to receive(:decode).and_return user_fields }

      it "returns a user model" do
        user = described_class.from_token("token")
        expect(user.email).to eq "example@gsa.gov"
      end
    end

    context "invalid JWT" do
      before(:each) { allow(JWT).to receive(:decode).and_raise JWT::DecodeError }
      it "returns nil" do
        expect(described_class.from_token("token")).to be_nil
      end
    end
  end

  describe "#asserted_attributes" do
    it "returns the attributes information" do
      expect(subject.asserted_attributes).to eq({
        email: {
          getter: :email,
          name_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS,
          name_id_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS
        }
      })
    end
  end
end
