/**
 * Legacy Project Proxy Dataset & Authorized View
 * Powered by Google Cloud Foundation Fabric (CFF) bigquery-dataset module
 * 
 * Mitigates downstream breakage when moving datasets between projects.
 * Downstream consumers (Looker, ETL microservices) querying `legacy_project.dataset.table`
 * seamlessly read from the new Landing Zone project via this delegated authorized view.
 */

module "legacy_proxy_dataset" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/bigquery-dataset?ref=v34.0.0"
  project_id = var.legacy_project_id
  id         = var.dataset_id
  location   = var.location

  labels = {
    lifecycle_phase = "migration-proxy-view"
    target_project  = var.project_id
    managed-by      = "terraform-cff"
  }

  # Authorized View redirecting queries to the target Landing Zone table
  views = {
    orders = {
      friendly_name  = "Orders Migration Proxy View"
      query          = "SELECT * FROM `${var.project_id}.${var.dataset_id}.orders`"
      use_legacy_sql = false
    }
  }
}
