variable "project_id" {
  description = "Target Landing Zone Service Project provisioned by Layer 2"
  type        = string
  default     = "corp-prod-analytics-eu"
}

variable "legacy_project_id" {
  description = "Brownfield legacy project hosting old dataset references"
  type        = string
  default     = "corp-legacy-analytics-old"
}

variable "location" {
  description = "Google Cloud region or multi-region for BigQuery storage"
  type        = string
  default     = "europe-west4"
}

variable "dataset_id" {
  description = "Identifier for the BigQuery analytical dataset"
  type        = string
  default     = "marketing_analytics"
}
