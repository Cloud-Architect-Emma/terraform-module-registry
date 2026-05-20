# ── Managed Identity ───────────────────────────────────────────────────────────

resource "azurerm_user_assigned_identity" "cluster" {
  name                = "${var.cluster_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ── AKS Cluster ────────────────────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix != "" ? var.dns_prefix : var.cluster_name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier
  tags                = var.tags

  default_node_pool {
    name                 = "system"
    vm_size              = var.system_node_pool.vm_size
    node_count           = var.system_node_pool.node_count
    min_count            = var.system_node_pool.min_count
    max_count            = var.system_node_pool.max_count
    enable_auto_scaling  = true
    vnet_subnet_id       = var.subnet_id
    os_disk_size_gb      = lookup(var.system_node_pool, "os_disk_size_gb", 128)
    type                 = "VirtualMachineScaleSets"

    node_labels = {
      "node.kubernetes.io/role" = "system"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cluster.id]
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    load_balancer_sku  = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

# ── Additional Node Pools ──────────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.additional_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  enable_auto_scaling   = true
  vnet_subnet_id        = var.subnet_id
  mode                  = lookup(each.value, "mode", "User")
  node_labels           = lookup(each.value, "labels", {})
  node_taints           = lookup(each.value, "taints", [])
  tags                  = var.tags
}
