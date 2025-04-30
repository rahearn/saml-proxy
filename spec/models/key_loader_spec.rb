# frozen_string_literal: true

require "rails_helper"

RSpec.describe KeyLoader, type: :model do
  subject { described_class }
  around(:each) do |example|
    subject.reset!
    example.run
    subject.reset!
  end

  describe ".key_str" do
    it "retrieves the token_keys url" do
      response = double
      expect(Faraday).to receive(:get).with(KeyLoader::KEYS_URL).and_return response
      expect(response).to receive(:body).and_return "body"
      expect(subject.key_str).to eq "body"
    end
  end

  describe ".key_set" do
    it "returns a JWK set", :vcr do
      expect(subject.key_set).to be_instance_of(JWT::JWK::Set)
    end
  end
end
