output "cluster_name" {
  value = aws_eks_cluster.this.name
}
output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}
output "cluster_ca_certificate" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}
output "cluster_version" {
  value = aws_eks_cluster.this.version
}
output "oidc_provider_arn" {
  value = var.enable_irsa ? aws_iam_openid_connect_provider.cluster[0].arn : null
}
output "oidc_provider_url" {
  value = var.enable_irsa ? aws_iam_openid_connect_provider.cluster[0].url : null
}
output "node_group_role_arn" {
  value = aws_iam_role.node_group.arn
}
