output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.eks.arn
}

output "cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks.name
}

output "node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = aws_iam_role.nodes.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}
