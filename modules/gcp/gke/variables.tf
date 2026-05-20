variable "cluster_name" { type = string }
variable "project_id" { type = string }
variable "region" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = string }
variable "cluster_version" { type = string; default = "latest" }
variable "pods_range_name" { type = string }
variable "services_range_name" { type = string }
variable "node_pools" {
  type = map(object({
    machine_type = string
    min_count    = number
    max_count    = number
    disk_size_gb = optional(number, 50)
    preemptible  = optional(bool, false)
  }))
  default = {
    default-pool = {
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 3
    }
  }
}
variable "labels" { type = map(string); default = {} }
