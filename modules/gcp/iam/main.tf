# ── Service Account ────────────────────────────────────────────────────────────

resource "google_service_account" "this" {
  account_id   = var.service_account_name
  display_name = var.display_name
  project      = var.project_id
}

# ── Project IAM Roles ──────────────────────────────────────────────────────────

resource "google_project_iam_member" "this" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.this.email}"
}

# ── Workload Identity binding (GKE) ───────────────────────────────────────────

resource "google_service_account_iam_member" "workload_identity" {
  count = var.k8s_service_account != "" ? 1 : 0

  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"
}
