terraform {
  required_version = "~> 1.10"
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.5.0"
    }
  }
  backend "http" {
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
# empty config will let terraform borrow cf-cli's auth
provider "cloudfoundry" {}

locals {
  orgs = {
    "staging"    = "cloud-gov-devtools-staging"
    "production" = "cloud-gov-devtools-production"
  }
  space_name = "devtools-saas-mgmt"
}

data "cloudfoundry_org" "org" {
  for_each = local.orgs
  name     = each.value
}

data "cloudfoundry_space" "mgmt_space" {
  for_each = local.orgs
  org      = data.cloudfoundry_org.org[each.key].id
  name     = local.space_name
}

data "cloudfoundry_service_plans" "cg_service_account" {
  name                  = "space-auditor"
  service_offering_name = "cloud-gov-service-account"
}
locals {
  sa_service_name               = "saml_proxy-cicd-deployer"
  sa_key_name                   = "cicd-deployer-access-key"
  staging_sa_bot_credentials    = jsondecode(data.cloudfoundry_service_credential_binding.runner_sa_key["staging"].credential_bindings.0.credential_binding).credentials
  production_sa_bot_credentials = jsondecode(data.cloudfoundry_service_credential_binding.runner_sa_key["production"].credential_bindings.0.credential_binding).credentials
  sa_cf_username = {
    "staging"    = nonsensitive(local.staging_sa_bot_credentials.username)
    "production" = nonsensitive(local.production_sa_bot_credentials.username)
  }
  sa_cf_password = {
    "staging"    = local.staging_sa_bot_credentials.password
    "production" = local.production_sa_bot_credentials.password
  }
}
resource "cloudfoundry_service_instance" "runner_service_account" {
  for_each     = local.orgs
  name         = local.sa_service_name
  type         = "managed"
  service_plan = data.cloudfoundry_service_plans.cg_service_account.service_plans.0.id
  space        = data.cloudfoundry_space.mgmt_space[each.key].id
}
resource "cloudfoundry_service_credential_binding" "runner_sa_key" {
  for_each         = local.orgs
  name             = local.sa_key_name
  service_instance = cloudfoundry_service_instance.runner_service_account[each.key].id
  type             = "key"
}
data "cloudfoundry_service_credential_binding" "runner_sa_key" {
  for_each         = local.orgs
  name             = local.sa_key_name
  service_instance = cloudfoundry_service_instance.runner_service_account[each.key].id
  depends_on       = [cloudfoundry_service_credential_binding.runner_sa_key]
}
data "cloudfoundry_user" "sa_user" {
  for_each = local.orgs
  name     = local.sa_cf_username[each.key]
}
resource "cloudfoundry_org_role" "sa_org_manager" {
  for_each = local.orgs
  user     = data.cloudfoundry_user.sa_user[each.key].users.0.id
  type     = "organization_manager"
  org      = data.cloudfoundry_org.org[each.key].id
}

resource "local_sensitive_file" "bot_secrets_file" {
  for_each        = local.orgs
  filename        = "${path.module}/secrets.${each.key}.tfvars"
  file_permission = "0600"

  content = templatefile("${path.module}/bot_secrets.tftpl", {
    service_name = local.sa_service_name,
    key_name     = local.sa_key_name,
    username     = local.sa_cf_username[each.key],
    password     = local.sa_cf_password[each.key]
  })
}
