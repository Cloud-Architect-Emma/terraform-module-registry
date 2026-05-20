variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "service_account_name" {
  description = "Service account ID (the part before @project.iam.gserviceaccount.com)"
  type        = string
}

variable "display_name" {
  description = "Human-readable display name for the service account"
  type        = string
  default     = ""
}

variable "roles" {
  description = "List of IAM roles to grant this service account at the project level"
  type        = list(string)
  default     = []
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

variable "cluster_name" {
  description = "GKE cluster name (informational, used for naming)"
  type        = string
  default     = ""
}
