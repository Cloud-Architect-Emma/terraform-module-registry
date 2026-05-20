variable "name" {
  description = "Name for the IAM role"
  type        = string
}

variable "assume_role_principals" {
  description = "Services or accounts that can assume this role"
  type = list(object({
    type        = string
    identifiers = list(string)
  }))
  default = []
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA (EKS workload identity)"
  type        = string
  default     = null
}

variable "oidc_provider_url" {
  description = "OIDC provider URL (without https://)"
  type        = string
  default     = null
}

variable "service_account_namespace" {
  description = "Kubernetes namespace for IRSA binding"
  type        = string
  default     = null
}

variable "service_account_name" {
  description = "Kubernetes service account name for IRSA binding"
  type        = string
  default     = null
}

variable "policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy name to JSON policy document"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
