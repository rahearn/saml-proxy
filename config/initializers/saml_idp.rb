SamlIdp.configure do |config|
  service_providers = {
    "GDG" => {
      response_hosts: ["gsa.gitlab-dedicated.us"]
    }
  }
  if Rails.env.staging?
    service_providers["CAPOC"] = {
      metadata_url: "https://capoc-saml.app.cloud.gov/users/auth/saml/metadata"
    }
  end
  base = ENV.fetch("BASE_SAML_LOCATION", "http://localhost:3000/saml")
  config.base_saml_location = base
  config.single_service_redirect_location = "#{base}/auth"
  config.service_provider.finder = ->(issuer_or_entity_id) do
    service_providers[issuer_or_entity_id]
  end
end
