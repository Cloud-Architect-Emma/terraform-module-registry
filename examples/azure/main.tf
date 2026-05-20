provider "azurerm" {
  features {}
}

# ── VNet ───────────────────────────────────────────────────────────────────────

module "vnet" {
  source = "../../modules/azure/vnet"

  name                  = var.name
  location              = var.location
  resource_group_name   = "${var.name}-rg"
  create_resource_group = true
  address_space         = ["10.0.0.0/16"]

  subnets = [
    {
      name               = "aks-nodes"
      cidr               = "10.0.0.0/22"
      create_nsg         = true
      create_route_table = false
    },
    {
      name               = "aks-pods"
      cidr               = "10.0.4.0/22"
      create_nsg         = true
    },
    {
      name              = "private-endpoints"
      cidr              = "10.0.8.0/24"
      create_nsg        = true
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
  ]

  tags = local.tags
}

# ── AKS ────────────────────────────────────────────────────────────────────────

module "aks" {
  source = "../../modules/azure/aks"

  cluster_name        = var.name
  location            = var.location
  resource_group_name = module.vnet.resource_group_name
  subnet_id           = module.vnet.subnet_ids["aks-nodes"]

  kubernetes_version = "1.29"
  sku_tier           = "Standard"

  system_node_pool = {
    vm_size    = "Standard_D2s_v3"
    node_count = 2
    min_count  = 1
    max_count  = 5
  }

  additional_node_pools = {
    user = {
      vm_size    = "Standard_D4s_v3"
      node_count = 1
      min_count  = 0
      max_count  = 10
      mode       = "User"
    }
  }

  network_plugin = "azure"
  network_policy = "azure"
  service_cidr   = "10.100.0.0/16"
  dns_service_ip = "10.100.0.10"

  tags = local.tags
}

# ── IAM — Workload Identity example ───────────────────────────────────────────

module "workload_identity" {
  source = "../../modules/azure/iam"

  name                = "${var.name}-workload"
  location            = var.location
  resource_group_name = module.vnet.resource_group_name

  oidc_issuer_url     = module.aks.oidc_issuer_url
  k8s_namespace       = "default"
  k8s_service_account = "workload-sa"

  role_assignments = [
    {
      scope     = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
      role_name = "Storage Blob Data Reader"
    }
  ]

  tags = local.tags
}

data "azurerm_client_config" "current" {}

locals {
  tags = {
    Name        = var.name
    Environment = "example"
    ManagedBy   = "terraform"
    Repo        = "terraform-module-registry"
  }
}
