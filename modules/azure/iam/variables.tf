variable "name" {
  description = "Name of the managed identity"
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

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from the AKS cluster"
  type        = string
  default     = ""
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for Workload Identity binding"
  type        = string
  default     = "default"
}

variable "k8s_service_account" {
  description = "Kubernetes service account name for Workload Identity binding"
  type        = string
  default     = ""
}

variable "role_assignments" {
  description = "List of role assignments for the managed identity"
  type = list(object({
    scope     = string
    role_name = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
