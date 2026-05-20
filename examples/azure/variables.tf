variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "example"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}
