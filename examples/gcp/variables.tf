variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "example"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west2"
}
