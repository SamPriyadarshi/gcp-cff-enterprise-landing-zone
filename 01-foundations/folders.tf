/**
 * Enterprise Resource Hierarchy (Folders)
 * Powered by Cloud Foundation Fabric (CFF) folder module
 */

module "top_level_folders" {
  source   = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/folder?ref=v34.0.0"
  for_each = toset(var.top_level_folders)

  parent = var.organization_id
  name   = each.key
}
