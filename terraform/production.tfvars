cf_space_name      = "saml-proxy-prod"
env                = "production"
custom_domain_name = null
host_name          = "saml-proxy"
web_instances      = 2
web_memory         = "512M"
space_auditors = [
  # enter cloud.gov usernames that should have access to audit logs
]
