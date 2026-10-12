output "vended_projects" {
  description = "Summary of projects provisioned across the enterprise fleet"
  value = {
    for k, v in module.service_projects : k => {
      project_id     = v.project_id
      project_number = v.number
      subnet_id      = google_compute_subnetwork.ipam_subnets[k].id
      cidr_range     = google_compute_subnetwork.ipam_subnets[k].ip_cidr_range
    }
  }
}
