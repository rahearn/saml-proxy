variable "cf_user" {
  type        = string
  description = "Current cf_user running this module"
}

locals {
  cf_org_name      = "gsa-tts-devtools-prototyping"
  cf_space_name    = "saml-dev-${var.cf_user}"
  uaa_service_name = "cloud-gov-identity-provider"
  uaa_dev_name     = "uaa_dev_creds"
}

module "space" {
  source = "github.com/gsa-tts/terraform-cloudgov//cg_space?ref=v2.3.0"

  cf_org_name   = local.cf_org_name
  cf_space_name = local.cf_space_name
  developers    = [var.cf_user]
}

data "cloudfoundry_service_plans" "uaa_service" {
  name                  = "oauth-client"
  service_offering_name = local.uaa_service_name
}

resource "cloudfoundry_service_instance" "uaa_authentication_service" {
  name         = "uaa-auth-service"
  type         = "managed"
  space        = module.space.space_id
  service_plan = data.cloudfoundry_service_plans.uaa_service.service_plans.0.id
  depends_on   = [module.space]
}

resource "cloudfoundry_service_credential_binding" "uaa_dev_creds" {
  name             = local.uaa_dev_name
  service_instance = cloudfoundry_service_instance.uaa_authentication_service.id
  type             = "key"
  parameters       = jsonencode({ redirect_uri = ["http://localhost:3000/oidc/callback"] })
}
data "cloudfoundry_service_credential_binding" "uaa_dev_creds" {
  name             = local.uaa_dev_name
  service_instance = cloudfoundry_service_instance.uaa_authentication_service.id
  depends_on       = [cloudfoundry_service_credential_binding.uaa_dev_creds]
}

locals {
  uaa_creds     = jsondecode(data.cloudfoundry_service_credential_binding.uaa_dev_creds.credential_bindings.0.credential_binding).credentials
  client_id     = local.uaa_creds.client_id
  client_secret = local.uaa_creds.client_secret
  env_contents  = <<-EOT
    VCAP_SERVICES="{\"${local.uaa_service_name}\": [{\"credentials\": {\"client_id\": \"${local.client_id}\", \"client_secret\": \"${local.client_secret}\"}}]}"
  EOT
}
resource "local_sensitive_file" "env_file" {
  filename = "${path.module}/../../.env.local"
  content  = local.env_contents
}
