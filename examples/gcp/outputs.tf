output "network_name" {
  value = module.vpc.network_name
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}

output "cluster_name" {
  value = module.gke.cluster_name
}

output "workload_identity_pool" {
  value = module.gke.workload_identity_pool
}
