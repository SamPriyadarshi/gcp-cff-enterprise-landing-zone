/**
 * Production BigQuery Dataset & Tables (Landing Zone Compliant)
 */

resource "google_bigquery_dataset" "marketing_analytics" {
  project    = var.project_id
  dataset_id = var.dataset_id
  location   = var.location

  labels = {
    team        = "marketing-analytics"
    cost-center = "marketing-finops"
    environment = "production"
  }
}

resource "google_bigquery_table" "orders" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.marketing_analytics.dataset_id
  table_id   = "orders"

  time_partitioning {
    type  = "DAY"
    field = "order_timestamp"
  }

  clustering = ["customer_id", "order_id"]

  schema = <<-EOF
  [
    {"name": "order_id", "type": "STRING", "mode": "REQUIRED", "description": "Unique transaction UUID"},
    {"name": "customer_id", "type": "STRING", "mode": "REQUIRED", "description": "Customer identifier"},
    {"name": "transaction_total", "type": "FLOAT", "mode": "REQUIRED", "description": "Total value in EUR"},
    {"name": "order_timestamp", "type": "TIMESTAMP", "mode": "REQUIRED", "description": "UTC order placement time"}
  ]
  EOF
}
