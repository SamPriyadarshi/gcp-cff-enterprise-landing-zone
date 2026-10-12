/**
 * Layer 3: Workload Applications
 * Owned by Product & Engineering Teams (e.g., Marketing Analytics)
 * 
 * APPLICATION TEAMS WORK HERE FREELY WITHOUT TOUCHING ORG PLUMBING:
 * - Deploy BigQuery Schemas & Tables
 * - Establish Authorized View Redirect Proxies for zero-downtime cutover
 * - Deploy Cloud Run with Direct VPC Egress
 */

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.20.0"
    }
  }
}

variable "project_id" {
  description = "Target Service Project provisioned by Layer 2"
  type        = string
  default     = "corp-prod-analytics-eu"
}

variable "location" {
  type    = string
  default = "europe-west4"
}

# ------------------------------------------------------------------------------
# 1. Target BigQuery Dataset (Landing Zone Compliant)
# ------------------------------------------------------------------------------
resource "google_bigquery_dataset" "marketing_analytics" {
  project    = var.project_id
  dataset_id = "marketing_analytics"
  location   = var.location

  labels = {
    team        = "marketing-analytics"
    cost-center = "marketing-finops"
  }
}

# ------------------------------------------------------------------------------
# 2. Production Orders Table (300 GB Migrated Table)
# ------------------------------------------------------------------------------
resource "google_bigquery_table" "orders" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.marketing_analytics.dataset_id
  table_id   = "orders"

  time_partitioning {
    type  = "DAY"
    field = "order_timestamp"
  }

  schema = <<-EOF
  [
    {"name": "order_id", "type": "STRING", "mode": "REQUIRED"},
    {"name": "customer_id", "type": "STRING", "mode": "REQUIRED"},
    {"name": "transaction_total", "type": "FLOAT", "mode": "REQUIRED"},
    {"name": "order_timestamp", "type": "TIMESTAMP", "mode": "REQUIRED"}
  ]
  EOF
}

# ------------------------------------------------------------------------------
# 3. Authorized View Redirect Proxy Pattern
# Allows downstream consumers to read without breaking dataset ID dependencies
# ------------------------------------------------------------------------------
resource "google_bigquery_table" "legacy_proxy_view" {
  project    = "corp-legacy-analytics-old" # Legacy Project
  dataset_id = "marketing_analytics"
  table_id   = "orders" # Downstream queries target this view transparently

  view {
    query          = "SELECT * FROM `${var.project_id}.${google_bigquery_dataset.marketing_analytics.dataset_id}.${google_bigquery_table.orders.table_id}`"
    use_legacy_sql = false
  }
}
