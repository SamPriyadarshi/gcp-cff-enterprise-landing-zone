# Booking.com GCP Landing Zone — 3-Layer CFF Reference Architecture

This repository demonstrates the production-grade **3-Layer Infrastructure-as-Code (IaC)** architecture powered by **Google Cloud Foundation Fabric (CFF)** tailored specifically for **Booking.com's enterprise scale and serverless footprint**.

---

## 🏛️ Do We Still Maintain 3 Layers with CFF?

**Yes, absolutely.** In fact, maintaining the 3-Layer separation is **even more critical and elegant with CFF** than with legacy frameworks.

### Why 3 Layers are Non-Negotiable at Booking.com Scale:

```
┌────────────────────────────────────────────────────────────────────────┐
│  Layer 1: Foundations (gcp-org-foundations)                            │
│  • Owner: Central Platform & SecOps Architecture                       │
│  • Scope: Org Policies (CIS v3.0), Folder Hierarchy, Root Log Sinks    │
│  • Impact: 1 Merge Request updates the entire Google Cloud Org         │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Inherited via Resource Manager)
┌───────────────────────────────────▼────────────────────────────────────┐
│  Layer 2: Baseline Project Factory (gcp-project-baseline)              │
│  • Owner: Core Platform Team (Automated via Passport & Nemo IPAM API)  │
│  • Scope: Service Projects, Nemo Subnets in Shared VPC, VPC-SC, IAM    │
│  • Impact: 1 Merge Request updates fleet-wide project baselines (500+) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Vends Compliant Foundation)
┌───────────────────────────────────▼────────────────────────────────────┐
│  Layer 3: Workload Applications (03-workload-apps)                     │
│  • Owner: Product & Data Engineering Teams (Decentralized)             │
│  • Scope: BigQuery Schemas, Vertex AI Models, Cloud Run Containers     │
│  • Impact: Continuous daily CI/CD without touching platform plumbing   │
└────────────────────────────────────────────────────────────────────────┘
```

1. **Blast Radius Control:** A developer updating a BigQuery schema in Layer 3 must **never** have the IAM permissions or capability to accidentally drift an Organization Policy or a root Log Sink.
2. **Independent CI/CD Pipelines:** Layer 1 changes once a quarter; Layer 2 triggers on-demand when projects are vended via Passport; Layer 3 deploys tens of times a day.
3. **Audit & Compliance Isolation:** External auditors and CSIRT only need to inspect Layer 1 and 2 for PCI/SOC2 compliance.

---

## 🚀 Repository Structure

```
├── 01-foundations/                  # Layer 1: Org Foundations (CFF modules)
│   └── main.tf                      # Folders, CIS Org Policies, Org Root Log Sink
│
├── 02-baseline/                     # Layer 2: Project Factory & Networking Baseline
│   ├── config/
│   │   └── projects.yaml            # Fleet registry (consumed by for_each)
│   └── main.tf                      # Automated Nemo IPAM subnets + Shared VPC attachment
│
└── 03-workload-apps/                # Layer 3: Application & Data Workloads
    └── team-marketing-analytics/
        └── main.tf                  # BigQuery table + Authorized View Redirect Proxy
```

---

## ⚡ Key Architectural Innovations in this Reference

### 1. Native Nemo IPAM & ECN Shared VPC Automation (Layer 2)
Subnets in the ECN Shared VPC are provisioned dynamically from the CIDR allocated by Booking's internal **Nemo IPAM API**:
```hcl
resource "google_compute_subnetwork" "nemo_subnets" {
  for_each      = local.projects_data
  name          = "sub-${each.key}-${local.region}"
  ip_cidr_range = each.value.nemo_allocated_cidr # Injected from Nemo IPAM
  network       = "projects/bkg-ecn-net-prod-eu/global/networks/bkg-shared-vpc-eu4"
}
```

### 2. BigQuery Zero-Downtime Authorized View Redirect Proxy (Layer 3)
When datasets migrate between projects, downstream queries continue without disruption using delegated views:
```hcl
resource "google_bigquery_table" "legacy_proxy_view" {
  project    = "bkg-legacy-analytics-old"
  dataset_id = "marketing_analytics"
  table_id   = "orders"

  view {
    query          = "SELECT * FROM `bkg-prod-analytics-eu.marketing_analytics.orders`"
    use_legacy_sql = false
  }
}
```

---

## 🤝 Pythian Alignment: Why CFF Accelerates Delivery
- **Composability:** CFF provides transparent, single-layer modules that make passing Nemo IPAM parameters effortless.
- **Velocity:** Pythian doesn't need to write custom wrapper code around deeply nested CFT modules.
- **Day-2 Operations:** Booking.com platform engineers get clean, standard HCL they can easily maintain.

---
*Maintained by Samrat Priyadarshi (Google Cloud PSO Engagement Lead & Delivery Architect)*
