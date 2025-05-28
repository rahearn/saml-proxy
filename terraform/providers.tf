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

provider "cloudfoundry" {}
