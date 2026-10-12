/**
 * Automated Enterprise IPAM Subnet Creation in Shared VPC
 * 
 * Ingests reserved non-overlapping CIDRs from enterprise IPAM platforms
 * (NetBox, Infoblox, or in-house IPAM REST endpoints) and binds them directly
 * to the centralized Shared VPC host project.
 */

resource "google_compute_subnetwork" "ipam_subnets" {
  for_each = local.projects_data

  name          = "sub-${each.key}-${var.default_region}"
  ip_cidr_range = each.value.ipam_allocated_cidr
  region        = var.default_region
  network       = "projects/${var.host_project_id}/global/networks/${var.shared_vpc_name}"
  project       = var.host_project_id

  private_ip_google_access = true

  # FinOps & Observability: 1% sampling rate to manage Cloud Logging costs
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.01
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
