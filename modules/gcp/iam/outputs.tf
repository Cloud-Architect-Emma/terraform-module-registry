output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.this.email
}

output "service_account_name" {
  description = "Full resource name of the service account"
  value       = google_service_account.this.name
}

output "workload_identity_member" {
  description = "Workload Identity member string for use in K8s annotations"
  value       = google_service_account.this.email
}
