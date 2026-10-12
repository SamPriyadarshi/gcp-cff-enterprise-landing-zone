/**
 * Project Factory Module (Composable Cloud Foundation Fabric)
 * 
 * Vends compliant Google Cloud service projects dynamically across the fleet.
 * Triggered automatically when developers submit requests through an internal developer portal.
 */

module "service_projects" {
  source   = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v34.0.0"
  for_each = local.projects_data

  name            = each.key
  parent          = each.value.folder_id
  billing_account = each.value.billing_account

  services = each.value.services

  labels = {
    environment = each.value.environment
    team        = each.value.team
    managed-by  = "terraform-cff"
    ipam-res-id = lower(each.value.ipam_reservation_id)
  }

  shared_vpc_service_config = {
    host_project = var.host_project_id
  }
}
