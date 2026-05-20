output "cluster_id" {
  description = "AKS cluster resource ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "cluster_endpoint" {
  description = "API server endpoint"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL (for Workload Identity)"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "cluster_identity_id" {
  description = "ID of the cluster user-assigned managed identity"
  value       = azurerm_user_assigned_identity.cluster.id
}
