variable "name" {
  description = "Name of the VPC network"
  type        = string
}
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "region" {
  description = "GCP region for subnets"
  type        = string
}
variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name                     = string
    cidr                     = string
    private_google_access    = optional(bool, true)
    secondary_ranges         = optional(list(object({ name = string, cidr = string })), [])
  }))
  default = []
}
variable "enable_flow_logs" {
  description = "Enable VPC flow logs on all subnets"
  type        = bool
  default     = true
}
variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}
