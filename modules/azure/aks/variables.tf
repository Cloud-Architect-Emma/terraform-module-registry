variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix (defaults to cluster_name)"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "AKS SKU tier: Free or Standard"
  type        = string
  default     = "Standard"
}

variable "subnet_id" {
  description = "Subnet ID for nodes"
  type        = string
}

variable "system_node_pool" {
  description = "System node pool configuration"
  type = object({
    vm_size         = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = optional(number, 128)
  })
  default = {
    vm_size    = "Standard_D2s_v3"
    node_count = 2
    min_count  = 1
    max_count  = 5
  }
}

variable "additional_node_pools" {
  description = "Map of additional node pool configurations"
  type = map(object({
    vm_size    = string
    node_count = number
    min_count  = number
    max_count  = number
    mode       = optional(string, "User")
    labels     = optional(map(string), {})
    taints     = optional(list(string), [])
  }))
  default = {}
}

variable "network_plugin" {
  description = "Network plugin: azure or kubenet"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy: azure or calico"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.100.0.0/16"
}

variable "dns_service_ip" {
  description = "IP for kube-dns service (must be within service_cidr)"
  type        = string
  default     = "10.100.0.10"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for OMS agent"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
