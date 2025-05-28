locals {
  cf_org_name     = "gsa-tts-devtools-prototyping"
  app_name        = "saml-proxy"
  space_deployers = setunion([var.cf_user], var.space_deployers)
}

module "app_space" {
  source = "github.com/gsa-tts/terraform-cloudgov//cg_space?ref=v2.3.0"

  cf_org_name   = local.cf_org_name
  cf_space_name = var.cf_space_name
  allow_ssh     = var.allow_ssh
  deployers     = local.space_deployers
  developers    = var.space_developers
  auditors      = var.space_auditors
}

module "app_route" {
  source = "github.com/gsa-tts/terraform-cloudgov//app_route?ref=v2.3.0"

  cf_org_name   = local.cf_org_name
  cf_space_name = var.cf_space_name
  app_ids       = [cloudfoundry_app.app.id]
  hostname      = var.host_name
  # depends_on line is required only for initial creation and destruction. It can be commented out for updates if you see unwanted cascading effects
  depends_on = [module.app_space]
}

module "egress_space" {
  source = "github.com/gsa-tts/terraform-cloudgov//cg_space?ref=v2.3.0"

  cf_org_name          = local.cf_org_name
  cf_space_name        = "${var.cf_space_name}-egress"
  allow_ssh            = var.allow_ssh
  deployers            = local.space_deployers
  developers           = var.space_developers
  auditors             = var.space_auditors
  security_group_names = ["public_networks_egress"]
}

module "egress_proxy" {
  source = "github.com/gsa-tts/terraform-cloudgov//egress_proxy?ref=v2.3.0"

  cf_org_name     = local.cf_org_name
  cf_egress_space = module.egress_space.space
  name            = "egress-proxy-${var.env}"
  instances       = var.web_instances
  allowlist = setunion(var.saml_hosts, [
    "uaa.fr.cloud.gov"
  ])
  # depends_on line is needed only for initial creation and destruction. It should be commented out for updates to prevent unwanted cascading effects
  depends_on = [module.app_space, module.egress_space]
}

resource "cloudfoundry_network_policy" "egress_routing" {
  policies = [
    {
      source_app      = cloudfoundry_app.app.id
      destination_app = module.egress_proxy.app_id
      port            = module.egress_proxy.https_port
    },
    {
      source_app      = cloudfoundry_app.app.id
      destination_app = module.egress_proxy.app_id
      port            = module.egress_proxy.http_port
    }
  ]
}

data "cloudfoundry_service_plans" "uaa_service" {
  name                  = "oauth-client"
  service_offering_name = "cloud-gov-identity-provider"
}

resource "cloudfoundry_service_instance" "uaa_authentication_service" {
  name         = "uaa-auth-service"
  type         = "managed"
  space        = module.app_space.space_id
  service_plan = data.cloudfoundry_service_plans.uaa_service.service_plans.0.id
  depends_on   = [module.app_space]
}
