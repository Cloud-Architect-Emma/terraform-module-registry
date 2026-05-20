output "network_id" { value = google_compute_network.this.id }
output "network_name" { value = google_compute_network.this.name }
output "network_self_link" { value = google_compute_network.this.self_link }
output "subnet_ids" { value = { for k, v in google_compute_subnetwork.this : k => v.id } }
output "subnet_self_links" { value = { for k, v in google_compute_subnetwork.this : k => v.self_link } }
