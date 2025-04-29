locals {
  cf_org_name     = "gsa-tts-devtools-prototyping"
  app_name        = "saml_proxy"
  space_deployers = setunion([var.cf_user], var.space_deployers)
}

module "app_space" {
  source = "github.com/gsa-tts/terraform-cloudgov//cg_space?ref=v2.3.0"

  cf_org_name          = local.cf_org_name
  cf_space_name        = var.cf_space_name
  allow_ssh            = var.allow_space_ssh
  deployers            = local.space_deployers
  developers           = var.space_developers
  auditors             = var.space_auditors
  security_group_names = ["trusted_local_networks_egress"]
}

module "database" {
  source = "github.com/gsa-tts/terraform-cloudgov//database?ref=v2.3.0"

  cf_space_id   = module.app_space.space_id
  name          = "${local.app_name}-rds-${var.env}"
  rds_plan_name = var.rds_plan_name
  # depends_on line is required only for initial creation and destruction. It can be commented out for updates if you see unwanted cascading effects
  depends_on = [module.app_space]
}

###########################################################################
# Before setting var.custom_domain_name, ensure the ACME challenge record has been created:
# See https://cloud.gov/docs/services/external-domain-service/#how-to-create-an-instance-of-this-service
###########################################################################
module "domain" {
  count  = (var.custom_domain_name == null ? 0 : 1)
  source = "github.com/gsa-tts/terraform-cloudgov//domain?ref=v2.3.0"

  cf_org_name   = local.cf_org_name
  cf_space      = module.app_space.space
  cdn_plan_name = "domain"
  domain_name   = var.custom_domain_name
  create_domain = true
  app_ids       = [cloudfoundry_app.app.id]
  host_name     = var.host_name
  # depends_on line is required only for initial creation and destruction. It can be commented out for updates if you see unwanted cascading effects
  depends_on = [module.app_space]
}
module "app_route" {
  count  = (var.custom_domain_name == null ? 1 : 0)
  source = "github.com/gsa-tts/terraform-cloudgov//app_route?ref=v2.3.0"

  cf_org_name   = local.cf_org_name
  cf_space_name = var.cf_space_name
  app_ids       = [cloudfoundry_app.app.id]
  hostname      = coalesce(var.host_name, "${local.app_name}-${var.env}")
  # depends_on line is required only for initial creation and destruction. It can be commented out for updates if you see unwanted cascading effects
  depends_on = [module.app_space]
}
