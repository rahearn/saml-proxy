cf_space_name   = "saml-proxy-staging"
env             = "staging"
allow_space_ssh = false
# host_name must be unique across cloud.gov, default is "saml_proxy-${var.env}"
host_name = "saml-proxy-staging"
space_developers = [
  # enter developer emails that should have ssh access to staging
  "ryan.ahearn@gsa.gov"
]
