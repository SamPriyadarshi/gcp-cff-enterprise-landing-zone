/**
 * IAM Least-Privilege & Serverless Direct VPC Egress Permissions
 * 
 * Binds the compute.networkUser role on specific subnets to each service project's
 * Cloud Run robot identity, enabling high-performance line-rate egress without connector VMs.
 */

resource "google_compute_subnetwork_iam_member" "cloudrun_network_user" {
  for_each = local.projects_data

  project    = var.host_project_id
  region     = var.default_region
  subnetwork = google_compute_subnetwork.ipam_subnets[each.key].name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${module.service_projects[each.key].number}@serverless-robot-prod.iam.gserviceaccount.com"
}
