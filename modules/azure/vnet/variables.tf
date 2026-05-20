variable "name" {
  description = "Name of the virtual network"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create the resource group (false = use existing)"
  type        = bool
  default     = true
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name               = string
    cidr               = string
    create_nsg         = optional(bool, true)
    create_route_table = optional(bool, false)
    service_endpoints  = optional(list(string), [])
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }), null)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
