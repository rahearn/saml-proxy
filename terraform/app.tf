data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/.."
  output_path = "${path.module}/dist/src.zip"
  excludes = [
    ".git*",
    ".circleci/*",
    ".bundle/*",
    "node_modules/*",
    "tmp/**/*",
    "terraform/*",
    "log/*",
    "doc/*"
  ]
}

locals {
  domain = coalesce(var.custom_domain_name, "app.cloud.gov")
}

resource "cloudfoundry_app" "app" {
  name       = "${local.app_name}-${var.env}"
  space_name = var.cf_space_name
  org_name   = local.cf_org_name

  path             = data.archive_file.src.output_path
  source_code_hash = data.archive_file.src.output_base64sha256
  buildpacks       = ["ruby_buildpack"]
  strategy         = "rolling"

  environment = {
    no_proxy                 = "apps.internal,s3-fips.us-gov-west-1.amazonaws.com"
    RAILS_ENV                = var.env
    RAILS_MASTER_KEY         = var.rails_master_key
    RAILS_LOG_TO_STDOUT      = "true"
    RAILS_SERVE_STATIC_FILES = "true"
  }

  processes = [
    {
      type                       = "web"
      instances                  = var.web_instances
      memory                     = var.web_memory
      health_check_http_endpoint = "/up"
      health_check_type          = "http"
      command                    = "exec env HTTP_PORT=$PORT ./bin/thrust ./bin/rails server"
    }
  ]

  service_bindings = [
    { service_instance = cloudfoundry_service_instance.egress_proxy_credentials.name },
    {
      service_instance = cloudfoundry_service_instance.uaa_authentication_service.name,
      params = jsonencode({
        redirect_uri = [
          "https://${var.host_name}.${local.domain}/oidc/callback"
        ]
      })
    }
  ]

  depends_on = [
    cloudfoundry_service_instance.egress_proxy_credentials,
    cloudfoundry_service_instance.uaa_authentication_service,
    module.app_space
  ]
}
