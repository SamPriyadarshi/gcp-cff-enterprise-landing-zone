locals {
  # Parse the central YAML projects inventory
  projects_data = yamldecode(file("${path.module}/${var.projects_registry_path}")).projects
}
