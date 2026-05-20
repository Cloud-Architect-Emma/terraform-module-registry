variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID to deploy the cluster into"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the cluster (use private subnets)"
  type        = list(string)
}

variable "node_groups" {
  description = "Map of managed node group configurations"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size_gb   = optional(number, 50)
    capacity_type  = optional(string, "ON_DEMAND")
  }))
  default = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "cluster_addons" {
  description = "EKS add-ons to enable"
  type        = map(object({ addon_version = optional(string) }))
  default = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
    aws-ebs-csi-driver = {}
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
