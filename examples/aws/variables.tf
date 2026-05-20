variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "example"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (cheaper for dev/test)"
  type        = bool
  default     = true
}
