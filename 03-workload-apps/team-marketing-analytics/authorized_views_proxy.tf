/**
 * Authorized View Redirect Proxy Pattern
 * 
 * Mitigates downstream breakage when moving datasets between projects.
 * Downstream consumers (Looker, ETL microservices) querying `legacy_project.dataset.table`
 * seamlessly read from the new Landing Zone project via this delegated authorized view.
 */

resource "google_bigquery_table" "legacy_proxy_view" {
  project    = var.legacy_project_id
  dataset_id = var.dataset_id
  table_id   = "orders"

  view {
    query          = "SELECT * FROM `${var.project_id}.${google_bigquery_dataset.marketing_analytics.dataset_id}.${google_bigquery_table.orders.table_id}`"
    use_legacy_sql = false
  }

  labels = {
    lifecycle_phase = "migration-proxy-view"
    target_project  = var.project_id
  }
}
