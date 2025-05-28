cf_space_name = "saml-proxy-prod"
env           = "production"
host_name     = "saml-proxy"
saml_hosts    = ["gsa.gitlab-dedicated.us"]
web_instances = 2
space_auditors = [
  # enter cloud.gov usernames that should have access to audit logs
  "ryan.ahearn@gsa.gov",
  "paul.hirsch@gsa.gov"
]
