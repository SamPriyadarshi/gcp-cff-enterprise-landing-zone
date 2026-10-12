variable "host_project_id" {
  description = "ECN Shared VPC Host Project ID"
  type        = string
  default     = "corp-net-hub-prod-eu"
}

variable "shared_vpc_name" {
  description = "Name of the enterprise Shared VPC network"
  type        = string
  default     = "corp-shared-vpc-eu4"
}

variable "default_region" {
  description = "Default Google Cloud region for infrastructure deployment"
  type        = string
  default     = "europe-west4"
}

variable "projects_registry_path" {
  description = "Relative or absolute path to the projects.yaml registry file"
  type        = string
  default     = "config/projects.yaml"
}
