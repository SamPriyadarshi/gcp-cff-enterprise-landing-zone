terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.20.0"
    }
  }

  # backend "gcs" {
  #   bucket = "corp-tfstate-baseline-prod"
  #   prefix = "baseline/state"
  # }
}

provider "google" {}
