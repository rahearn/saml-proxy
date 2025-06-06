# Deploy user settings
variable "cf_user" {
  type        = string
  description = "The user email or service account running the terraform"
}

# app_space settings
variable "cf_org_name" {
  type        = string
  description = "The org name to deploy the app into"
}
variable "cf_space_name" {
  type        = string
  description = "The space name to deploy the app into"
}
variable "space_deployers" {
  type        = set(string)
  default     = []
  description = "A list of users to be granted SpaceDeveloper & SpaceManager on cf_space_name"
}
variable "space_developers" {
  type        = set(string)
  default     = []
  description = "A list of users to be granted SpaceDeveloper on cf_space_name"
}
variable "space_auditors" {
  type        = set(string)
  default     = []
  description = "A list of users to be granted SpaceAuditor on cf_space_name"
}
variable "allow_ssh" {
  type        = bool
  default     = false
  description = "Whether to allow ssh to the space and/or app"
}

# routing settings
variable "host_name" {
  type        = string
  description = "An optional hostname to prepend to either the custom domain name or app.cloud.gov"
}

# App environment settings
variable "env" {
  type        = string
  description = "The RAILS_ENV to set for the app (staging or production)"
}

variable "rails_master_key" {
  type        = string
  sensitive   = true
  description = "config/master.key"
}

variable "web_instances" {
  type        = number
  default     = 1
  description = "The number of instances of the web process"
}
variable "web_memory" {
  type        = string
  default     = "256M"
  description = "The amount of memory to assign to the web processes"
}

variable "saml_hosts" {
  type        = set(string)
  description = "The hosts that the app can redirect users back to"
  default = [
    "gsa.gitlab-dedicated.us"
  ]
}
