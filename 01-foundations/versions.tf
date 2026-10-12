terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.20.0"
    }
  }

  # In production, state is protected with customer-managed encryption keys (CMEK)
  # backend "gcs" {
  #   bucket = "corp-tfstate-foundations-prod"
  #   prefix = "foundations/state"
  # }
}

provider "google" {
  # Root administrative credentials or WIF impersonation
}
