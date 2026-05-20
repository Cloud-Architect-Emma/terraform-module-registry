resource "google_service_account" "cluster" {
  account_id   = "${var.cluster_name}-sa"
  display_name = "GKE cluster service account for ${var.cluster_name}"
  project      = var.project_id
}

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_auth {
    client_certificate_config { issue_client_certificate = false }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
}

resource "google_container_node_pool" "this" {
  for_each   = var.node_pools
  name       = each.key
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.this.name

  autoscaling {
    min_node_count = each.value.min_count
    max_node_count = each.value.max_count
  }

  node_config {
    machine_type    = each.value.machine_type
    disk_size_gb    = each.value.disk_size_gb
    preemptible     = each.value.preemptible
    service_account = google_service_account.cluster.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    workload_metadata_config { mode = "GKE_METADATA" }
  }
}
