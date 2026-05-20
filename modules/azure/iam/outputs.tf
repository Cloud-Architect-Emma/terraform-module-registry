output "identity_id" {
  description = "Resource ID of the managed identity"
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "Client ID of the managed identity (use in K8s service account annotation)"
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.this.principal_id
}
