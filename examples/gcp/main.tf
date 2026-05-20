provider "google" {
  project = var.project_id
  region  = var.region
}

# ── VPC ────────────────────────────────────────────────────────────────────────

module "vpc" {
  source = "../../modules/gcp/vpc"

  name       = var.name
  project_id = var.project_id

  subnets = [
    {
      name   = "${var.name}-nodes"
      region = var.region
      cidr   = "10.0.0.0/20"
      secondary_ranges = [
        { range_name = "pods",     cidr = "10.48.0.0/14" },
        { range_name = "services", cidr = "10.52.0.0/20" }
      ]
    },
    {
      name   = "${var.name}-private"
      region = var.region
      cidr   = "10.0.16.0/20"
    }
  ]

  enable_cloud_nat = true
  allow_ssh_iap    = true
}

# ── GKE ────────────────────────────────────────────────────────────────────────

module "gke" {
  source = "../../modules/gcp/gke"

  cluster_name = var.name
  project_id   = var.project_id
  location     = var.region

  network    = module.vpc.network_name
  subnetwork = "${var.name}-nodes"

  pods_range_name     = "pods"
  services_range_name = "services"

  enable_private_nodes   = true
  master_ipv4_cidr_block = "172.16.0.0/28"

  master_authorized_networks = [
    { cidr_block = "0.0.0.0/0", display_name = "all" }
  ]

  node_pools = {
    default = {
      machine_type   = "e2-standard-2"
      min_node_count = 1
      max_node_count = 5
    }
    spot = {
      machine_type   = "e2-standard-2"
      min_node_count = 0
      max_node_count = 10
      spot           = true
      labels = {
        "node.kubernetes.io/lifecycle" = "spot"
      }
    }
  }
}

# ── IAM — Workload Identity example ───────────────────────────────────────────

module "workload_sa" {
  source = "../../modules/gcp/iam"

  project_id           = var.project_id
  service_account_name = "${var.name}-workload"
  display_name         = "Workload Identity example SA"

  k8s_namespace       = "default"
  k8s_service_account = "workload-sa"
  cluster_name        = module.gke.cluster_name

  roles = ["roles/storage.objectViewer"]
}
