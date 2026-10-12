variable "organization_id" {
  description = "Enterprise Google Cloud Organization ID (format: organizations/123456789012)"
  type        = string
  default     = "organizations/123456789012"
}

variable "billing_account" {
  description = "Master Cloud Billing Account ID"
  type        = string
  default     = "01ABCD-23EF45-6789GH"
}

variable "top_level_folders" {
  description = "Standard top-level environment folders created under the organization root"
  type        = list(string)
  default = [
    "data-analytics",
    "ml-engineering",
    "shared-services",
    "security-operations"
  ]
}

variable "security_logging_project_id" {
  description = "Dedicated central security & logging audit project ID"
  type        = string
  default     = "corp-sec-logging-prod"
}
