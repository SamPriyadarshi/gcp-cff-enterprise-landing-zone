/**
 * Layer 2: Baseline (gcp-project-baseline)
 * Powered by Cloud Foundation Fabric (CFF)
 * 
 * 1 MR TO THIS REPO VENDS & UPDATES FLEET-WIDE PROJECT BASELINES VIA `for_each`:
 * - Native Nemo IPAM CIDR Subnet Provisioning in ECN Shared VPC
 * - Automatic VPC Service Controls (VPC-SC) Perimeter Membership
 * - Automated CMEK & Least-Privilege IAM Baseline
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

locals {
  # Ingest the projects registry
  projects_data = yamldecode(file("${path.module}/config/projects.yaml")).projects
  
  host_project_id = "bkg-ecn-net-prod-eu"
  shared_vpc_name = "bkg-shared-vpc-eu4"
  region          = "europe-west4"
}

# ------------------------------------------------------------------------------
# 1. Project Factory (CFF Composable Module)
# Instantiates compliant Service Projects in parallel using for_each
# ------------------------------------------------------------------------------
module "service_projects" {
  source   = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v34.0.0"
  for_each = local.projects_data

  name            = each.key
  parent          = each.value.folder_id
  billing_account = each.value.billing_account

  services = each.value.services

  labels = {
    environment    = each.value.environment
    team           = each.value.team
    managed-by     = "terraform-cff"
    nemo-res-id    = lower(each.value.nemo_reservation_id)
  }

  shared_vpc_service_config = {
    host_project = local.host_project_id
  }
}

# ------------------------------------------------------------------------------
# 2. Automated Nemo IPAM Subnet Creation in ECN Shared VPC
# Eliminates manual IP allocation and prevents on-prem BGP overlap
# ------------------------------------------------------------------------------
resource "google_compute_subnetwork" "nemo_subnets" {
  for_each = local.projects_data

  name          = "sub-${each.key}-${local.region}"
  ip_cidr_range = each.value.nemo_allocated_cidr
  region        = local.region
  network       = "projects/${local.host_project_id}/global/networks/${local.shared_vpc_name}"
  project       = local.host_project_id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.01 # FinOps: 1% sampling to control ingestion costs
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ------------------------------------------------------------------------------
# 3. Grant Service Project Cloud Run Service Agent access to use Nemo Subnet
# Enables Direct VPC Egress without Serverless VPC Connectors
# ------------------------------------------------------------------------------
resource "google_compute_subnetwork_iam_member" "cloudrun_network_user" {
  for_each = local.projects_data

  project    = local.host_project_id
  region     = local.region
  subnetwork = google_compute_subnetwork.nemo_subnets[each.key].name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${module.service_projects[each.key].number}@serverless-robot-prod.iam.gserviceaccount.com"
}
