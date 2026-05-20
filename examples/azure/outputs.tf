output "vnet_id" {
  value = module.vnet.vnet_id
}

output "subnet_ids" {
  value = module.vnet.subnet_ids
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}
