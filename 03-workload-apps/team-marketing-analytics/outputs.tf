output "target_dataset_id" {
  description = "Fully qualified ID of the target BigQuery dataset"
  value       = module.target_bigquery_dataset.id
}

output "target_tables" {
  description = "IDs of tables managed in the target dataset"
  value       = module.target_bigquery_dataset.table_ids
}

output "proxy_view_id" {
  description = "Fully qualified ID of the legacy authorized proxy view"
  value       = module.legacy_proxy_dataset.view_ids["orders"]
}
