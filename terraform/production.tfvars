cf_space_name      = "saml-proxy-prod"
env                = "production"
rds_plan_name      = "TKTK-production-rds-plan"
custom_domain_name = null
host_name          = null
web_instances      = 2
web_memory         = "512M"



space_auditors = [
  # enter cloud.gov usernames that should have access to audit logs
]
