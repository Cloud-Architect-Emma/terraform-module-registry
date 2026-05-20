output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "nsg_ids" {
  description = "Map of subnet name to NSG ID"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}
