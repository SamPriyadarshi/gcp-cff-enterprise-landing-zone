# Enterprise Google Cloud Landing Zone — 3-Layer CFF Reference Architecture

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Google Cloud Foundation Fabric](https://img.shields.io/badge/CFF-v34.0.0-4285F4?logo=google-cloud)](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A production-grade, open-source reference architecture demonstrating a **3-Layer Infrastructure-as-Code (IaC)** model built with **Google Cloud Foundation Fabric (CFF)**. Designed for hyperscale enterprise environments characterized by **automated project vending, centralized IPAM, Shared VPC networking, and serverless Data & AI workloads**.

---

## 🏛️ Architectural Overview: The 3-Layer Decoupled Model

In enterprise environments with hundreds of projects, bundling organization policies and application workloads into a single Terraform state leads to catastrophic blast radiuses, slow plans, and state locking contention.

This reference implements a strictly decoupled 3-tier structure:

```
┌────────────────────────────────────────────────────────────────────────┐
│  Layer 1: Foundations (01-foundations)                                 │
│  • Owner: Central Cloud Platform & SecOps Architecture                 │
│  • Scope: Org Policies (CIS v3.0), Folder Hierarchy, Root Log Sinks    │
│  • Impact: 1 Merge Request updates the entire Google Cloud Org         │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Auto-Inherited via Resource Manager)
┌───────────────────────────────────▼────────────────────────────────────┐
│  Layer 2: Baseline Project Factory (02-baseline)                       │
│  • Owner: Core Platform (Triggered via Project Vending API / CI/CD)    │
│  • Scope: Service Projects, IPAM Subnets in Shared VPC, VPC-SC, IAM    │
│  • Impact: 1 Merge Request updates fleet-wide project baselines (500+) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Vends Standardized Foundation)
┌───────────────────────────────────▼────────────────────────────────────┐
│  Layer 3: Workload Applications (03-workload-apps)                     │
│  • Owner: Product & Data Engineering Teams (Decentralized)             │
│  • Scope: BigQuery Schemas, Vertex AI Endpoints, Cloud Run Services    │
│  • Impact: Continuous daily CI/CD without touching platform plumbing   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Repository Structure

```
gcp-cff-enterprise-landing-zone/
├── 01-foundations/                  # Layer 1: Org Foundations (CFF modules)
│   └── main.tf                      # Folders, CIS Org Policies, Root Audit Log Sink
│
├── 02-baseline/                     # Layer 2: Project Factory & Networking Baseline
│   ├── config/
│   │   └── projects.yaml            # Fleet registry (consumed by for_each)
│   └── main.tf                      # Automated IPAM subnets + Shared VPC attachment
│
└── 03-workload-apps/                # Layer 3: Application & Data Workloads
    └── team-marketing-analytics/
        └── main.tf                  # BigQuery table + Authorized View Redirect Proxy
```

---

## ⚡ Key Architectural Patterns

### 1. Dynamic IPAM Subnet Allocation (Layer 2)
Subnets in the Shared VPC are provisioned dynamically from CIDRs allocated by an enterprise IPAM platform (e.g., Infoblox, NetBox, or internal REST APIs), guaranteeing zero IP overlap across hybrid datacenters:

```hcl
resource "google_compute_subnetwork" "ipam_subnets" {
  for_each      = local.projects_data
  name          = "sub-${each.key}-${local.region}"
  ip_cidr_range = each.value.ipam_allocated_cidr # Injected from IPAM registry
  network       = "projects/corp-net-hub-prod-eu/global/networks/corp-shared-vpc-eu4"
}
```

### 2. BigQuery Zero-Downtime Migration Pattern (Layer 3)
When migrating datasets to new landing zone projects with different project IDs, downstream dashboards and microservices continue querying without breakage via the **Authorized View Redirect Proxy** pattern:

```hcl
resource "google_bigquery_table" "legacy_proxy_view" {
  project    = "corp-legacy-analytics-old"
  dataset_id = "marketing_analytics"
  table_id   = "orders"

  view {
    query          = "SELECT * FROM `corp-prod-analytics-eu.marketing_analytics.orders`"
    use_legacy_sql = false
  }
}
```

### 3. Serverless Direct VPC Egress
Bypasses legacy Serverless VPC Access connector VMs. Cloud Run services attach directly to the enterprise Shared VPC subnet at line rate with zero connector management overhead.

---

## 🛠️ Getting Started

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- Google Cloud SDK (`gcloud`) authenticated with administrative permissions

### Deployment Sequence
1. **Deploy Foundations:**
   ```bash
   cd 01-foundations
   terraform init && terraform plan
   ```
2. **Deploy Baseline Projects:**
   ```bash
   cd ../02-baseline
   terraform init && terraform plan
   ```
3. **Deploy Workload Apps:**
   ```bash
   cd ../03-workload-apps/team-marketing-analytics
   terraform init && terraform plan
   ```

---

## 📄 License
Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
