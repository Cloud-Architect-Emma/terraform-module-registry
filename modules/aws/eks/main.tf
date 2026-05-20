locals {
  tags = merge(var.tags, { ManagedBy = "terraform", ClusterName = var.cluster_name })
}

# Cluster IAM role
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policies" {
  for_each   = toset(["AmazonEKSClusterPolicy", "AmazonEKSVPCResourceController"])
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# Cluster security group
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${var.cluster_name}-cluster-sg" })
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  depends_on = [aws_iam_role_policy_attachment.cluster_policies]
  tags = local.tags
}

# IRSA - OIDC Provider
data "tls_certificate" "cluster" {
  count = var.enable_irsa ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  count           = var.enable_irsa ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  tags            = local.tags
}

# Node group IAM role
resource "aws_iam_role" "node_group" {
  name = "${var.cluster_name}-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "node_group_policies" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# Managed node groups
resource "aws_eks_node_group" "this" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type

  scaling_config {
    min_size     = each.value.min_size
    max_size     = each.value.max_size
    desired_size = each.value.desired_size
  }

  disk_size  = each.value.disk_size_gb
  depends_on = [aws_iam_role_policy_attachment.node_group_policies]
  tags       = merge(local.tags, { NodeGroup = each.key })
}

# Add-ons
resource "aws_eks_addon" "this" {
  for_each      = var.cluster_addons
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = each.key
  addon_version = try(each.value.addon_version, null)
  depends_on    = [aws_eks_node_group.this]
  tags          = local.tags
}
