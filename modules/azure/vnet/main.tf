# ── Resource Group (optional — can use existing) ───────────────────────────────

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : var.resource_group_name
}

# ── Virtual Network ────────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# ── Subnets ────────────────────────────────────────────────────────────────────

resource "azurerm_subnet" "this" {
  for_each = { for s in var.subnets : s.name => s }

  name                 = each.value.name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr]

  service_endpoints = lookup(each.value, "service_endpoints", [])

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# ── Network Security Groups ────────────────────────────────────────────────────

resource "azurerm_network_security_group" "this" {
  for_each = { for s in var.subnets : s.name => s if lookup(s, "create_nsg", true) }

  name                = "${each.value.name}-nsg"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for s in var.subnets : s.name => s if lookup(s, "create_nsg", true) }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

# ── Route Tables ───────────────────────────────────────────────────────────────

resource "azurerm_route_table" "this" {
  for_each = { for s in var.subnets : s.name => s if lookup(s, "create_route_table", false) }

  name                = "${each.value.name}-rt"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for s in var.subnets : s.name => s if lookup(s, "create_route_table", false) }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this[each.key].id
}
