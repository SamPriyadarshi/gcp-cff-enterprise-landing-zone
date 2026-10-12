/**
 * Organization-Level Aggregated Log Sink
 * 
 * Captures Organization administrative blind spots:
 * - Organization Policy modifications
 * - IAM Role & Superadmin additions
 * - Folder creation / deletion / moves
 * - Access Context Manager VPC-SC perimeter modifications
 */

resource "google_logging_organization_sink" "org_admin_audit_sink" {
  name        = "corp-org-admin-audit-sink"
  org_id      = replace(var.organization_id, "organizations/", "")
  destination = "logging.googleapis.com/projects/${var.security_logging_project_id}/locations/global/buckets/org-audit-bucket"

  filter = <<-EOT
    logName:"logs/cloudaudit.googleapis.com%2Factivity" OR
    logName:"logs/cloudaudit.googleapis.com%2Fpolicy"
  EOT

  # include_children is false to isolate root-level events from child folder sinks
  include_children = false
}

# IAM binding allowing the Org Sink writer identity to write into the security logging bucket
resource "google_project_iam_member" "org_sink_writer" {
  project = var.security_logging_project_id
  role    = "roles/logging.bucketWriter"
  member  = google_logging_organization_sink.org_admin_audit_sink.writer_identity
}
