/**
 * Layer 1: Foundations (gcp-org-foundations)
 * Powered by Google Cloud Foundation Fabric (CFF)
 * 
 * 1 MR TO THIS REPO GOVERNS THE ENTIRE ORGANIZATION VIA INHERITANCE:
 * - Enterprise Folder Hierarchy
 * - CIS GCP Benchmark v3.0 Org Policies
 * - Centralized Organization Log Sink (Eliminates Org Administrative Blindspots)
 */

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.20.0"
    }
  }
}

variable "organization_id" {
  description = "Enterprise Google Cloud Organization ID"
  type        = string
  default     = "organizations/123456789012"
}

variable "billing_account" {
  description = "Master Cloud Billing Account ID"
  type        = string
  default     = "01ABCD-23EF45-6789GH"
}

# ------------------------------------------------------------------------------
# 1. Organization Resource Hierarchy (Folders)
# ------------------------------------------------------------------------------
module "org_folders" {
  source   = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/folder?ref=v34.0.0"
  for_each = toset(["data-analytics", "ml-engineering", "shared-services", "security-operations"])

  parent = var.organization_id
  name   = each.key
}

# ------------------------------------------------------------------------------
# 2. CIS v3.0 Organization Policies (Applied at Org Root)
# ------------------------------------------------------------------------------
module "org_policies" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/organization?ref=v34.0.0"
  org_id = var.organization_id

  org_policies = {
    # Prohibit external service account key creation (Forces Workload Identity / WIF)
    "iam.disableServiceAccountKeyCreation" = {
      rules = [{ enforce = true }]
    }
    # Enforce Uniform Bucket-Level Access across Cloud Storage
    "storage.uniformBucketLevelAccess" = {
      rules = [{ enforce = true }]
    }
    # Prohibit public IP assignment on Compute / Serverless
    "compute.vmExternalIpAccess" = {
      rules = [{ enforce = true }]
    }
    # Restrict VPC Peering to prevent uncontrolled mesh networking
    "compute.restrictVpcPeering" = {
      rules = [{ enforce = true }]
    }
  }
}

# ------------------------------------------------------------------------------
# 3. Organization-Level Aggregated Log Sink
# Captures Org-level administrative blind spots (Org Policy changes, IAM superadmins)
# ------------------------------------------------------------------------------
resource "google_logging_organization_sink" "org_admin_audit_sink" {
  name        = "corp-org-admin-audit-sink"
  org_id      = replace(var.organization_id, "organizations/", "")
  destination = "logging.googleapis.com/projects/corp-sec-logging-prod/locations/global/buckets/org-audit-bucket"

  filter = <<-EOT
    logName:"logs/cloudaudit.googleapis.com%2Factivity" OR
    logName:"logs/cloudaudit.googleapis.com%2Fpolicy"
  EOT

  include_children = false # Specifically captures org-root events (folders capture their own children)
}
