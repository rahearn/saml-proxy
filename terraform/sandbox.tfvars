cf_org_name   = "gsa-tts-devtools-prototyping"
cf_space_name = "saml-proxy-sandbox"
env           = "staging"
allow_ssh     = true
# host_name must be unique across cloud.gov, default is "saml_proxy-${var.env}"
host_name  = "saml-proxy-sandbox"
saml_hosts = ["capoc-saml.app.cloud.gov"]
cf_user    = "ryan.ahearn@gsa.gov"
