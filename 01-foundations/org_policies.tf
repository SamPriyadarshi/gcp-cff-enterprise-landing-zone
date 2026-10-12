/**
 * CIS Google Cloud Benchmark v3.0 Organization Policies
 * Applied globally at the organization root node
 */

module "org_policies" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/organization?ref=v34.0.0"
  org_id = var.organization_id

  org_policies = {
    # CIS 1.1: Restrict Service Account Key Creation
    "iam.disableServiceAccountKeyCreation" = {
      rules = [{ enforce = true }]
    }

    # CIS 1.2: Restrict Service Account Key Upload
    "iam.disableServiceAccountKeyUpload" = {
      rules = [{ enforce = true }]
    }

    # CIS 2.1: Enforce Uniform Bucket-Level Access
    "storage.uniformBucketLevelAccess" = {
      rules = [{ enforce = true }]
    }

    # CIS 3.1: Prohibit Public IP Assignment on VMs / Serverless
    "compute.vmExternalIpAccess" = {
      rules = [{ enforce = true }]
    }

    # Restrict unmanaged VPC Peering (Enforces Shared VPC Hub-and-Spoke)
    "compute.restrictVpcPeering" = {
      rules = [{ enforce = true }]
    }

    # Restrict public sharing on Cloud Storage
    "storage.publicAccessPrevention" = {
      rules = [{ enforce = true }]
    }
  }
}
