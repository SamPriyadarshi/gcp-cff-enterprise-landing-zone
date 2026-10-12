output "target_dataset_id" {
  description = "Fully qualified ID of the target BigQuery dataset"
  value       = "${var.project_id}.${google_bigquery_dataset.marketing_analytics.dataset_id}"
}

output "proxy_view_id" {
  description = "Fully qualified ID of the legacy authorized proxy view"
  value       = "${var.legacy_project_id}.${var.dataset_id}.orders"
}
