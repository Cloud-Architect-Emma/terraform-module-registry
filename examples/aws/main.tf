provider "aws" {
  region = var.region
}

# ── VPC ────────────────────────────────────────────────────────────────────────

module "vpc" {
  source = "../../modules/aws/vpc"

  name = var.name
  cidr = "10.0.0.0/16"
  azs  = ["${var.region}a", "${var.region}b", "${var.region}c"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  tags = local.tags
}

# ── EKS ────────────────────────────────────────────────────────────────────────

module "eks" {
  source = "../../modules/aws/eks"

  cluster_name       = var.name
  kubernetes_version = "1.29"
  subnet_ids         = module.vpc.private_subnet_ids

  node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 4
      min_size       = 1
    }
    spot = {
      instance_types = ["t3.medium", "t3.large"]
      desired_size   = 1
      max_size       = 10
      min_size       = 0
      capacity_type  = "SPOT"
      labels = {
        "node.kubernetes.io/lifecycle" = "spot"
      }
    }
  }

  tags = local.tags
}

# ── IAM — IRSA example for a workload ─────────────────────────────────────────

module "s3_reader_role" {
  source = "../../modules/aws/iam"

  role_name         = "${var.name}-s3-reader"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  k8s_namespace     = "default"
  k8s_service_account = "s3-reader"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]

  tags = local.tags
}

locals {
  tags = {
    Name        = var.name
    Environment = "example"
    ManagedBy   = "terraform"
    Repo        = "terraform-module-registry"
  }
}
