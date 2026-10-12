/**
 * Production BigQuery Dataset & Tables (Landing Zone Compliant)
 * Powered by Google Cloud Foundation Fabric (CFF) bigquery-dataset module
 * 
 * Key Advantages of using CFF Module:
 * - Native management of dataset access policies and IAM roles
 * - Native authorized_views declaration allowing delegated queries across projects
 * - Data-driven tables and views configuration with partitioning & clustering
 */

locals {
  orders_table_schema = jsonencode([
    { name = "order_id", type = "STRING", mode = "REQUIRED", description = "Unique transaction UUID" },
    { name = "customer_id", type = "STRING", mode = "REQUIRED", description = "Customer identifier" },
    { name = "transaction_total", type = "FLOAT", mode = "REQUIRED", description = "Total value in EUR" },
    { name = "order_timestamp", type = "TIMESTAMP", mode = "REQUIRED", description = "UTC order placement time" }
  ])
}

module "target_bigquery_dataset" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/bigquery-dataset?ref=v34.0.0"
  project_id = var.project_id
  id         = var.dataset_id
  location   = var.location

  labels = {
    team        = "marketing-analytics"
    cost-center = "marketing-finops"
    environment = "production"
    managed-by  = "terraform-cff"
  }

  # Production Table with Day Partitioning and Customer Clustering
  tables = {
    orders = {
      friendly_name       = "Production Orders Table"
      schema              = local.orders_table_schema
      deletion_protection = true
      partitioning = {
        time = {
          type  = "DAY"
          field = "order_timestamp"
        }
      }
      clustering = ["customer_id", "order_id"]
    }
  }

  # Authorize the legacy project's proxy view to read this dataset without exposing raw tables
  authorized_views = [
    {
      project_id = var.legacy_project_id
      dataset_id = var.dataset_id
      table_id   = "orders"
    }
  ]
}
