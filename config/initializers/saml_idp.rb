SamlIdp.configure do |config|
  service_providers = {
    "GDG" => {
      response_hosts: ["gsa.gitlab-dedicated.us"]
    },
    "CAPOC" => {
      response_hosts: ["capoc-saml.app.cloud.gov"]
    }
  }
  config.entity_id = "UAA-SAML-Proxy"
  config.service_provider.finder = ->(issuer_or_entity_id) do
    service_providers[issuer_or_entity_id]
  end
end
