service_providers = {
  "GDG" => {
    validate_signature: true,
    sign_authn_request: true,
    fingerprint: "",
    response_hosts: ["gsa.gitlab-dedicated.us"]
  }
}
sp_metadata = {}

SamlIdp.configure do |config|
  base = ENV.fetch("BASE_SAML_LOCATION", "http://localhost:3000/saml")
  config.base_saml_location = base
  config.single_service_redirect_location = "#{base}/auth"

  config.algorithm = :sha256

  cert = Rails.root.join "config", "x509.pem"
  saml_secret_key = Rails.application.credentials.saml_secret_key
  if saml_secret_key.present? && File.exist?(cert)
    config.x509_certificate = File.read(cert)
    config.secret_key = saml_secret_key
  end

  config.service_provider.finder = ->(issuer_or_entity_id) do
    service_providers[issuer_or_entity_id]
  end
  config.service_provider.metadata_persister = ->(id, settings) {
    sp_metadata[id] = settings
  }
  config.service_provider.persisted_metadata_getter = ->(id, service_provider) {
    sp_metadata.fetch(id) { |_| service_provider.refresh_metadata }&.to_h
  }
end

if !Rails.env.production?
  service_providers["CAPOC"] = {
    validate_signature: true,
    sign_authn_request: true,
    fingerprint: "35:F2:D0:60:3E:6D:2A:8D:5F:04:47:3B:C5:8C:DF:14:B7:F7:F5:DB:17:5B:2B:84:6A:73:76:35:FB:69:CD:F1",
    metadata_url: "https://continuous_monitoring-staging.app.cloud.gov/users/auth/saml/metadata"
  }
end
if Rails.env.local?
  service_providers["CAPOC"][:metadata_url] = "http://localhost:3001/users/auth/saml/metadata"
end
