#-------------Backend-----------------

# output "s3_bucket_name" {
#   description = "S3 bucket with Terraform state"
#   value       = module.s3_backend.s3_bucket_name
# }
#
# output "dynamodb_table_name" {
#   description = "DynamoDB table with Terraform state lock"
#   value       = module.s3_backend.dynamodb_table_name
# }

#-------------VPC-----------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnets"
  value       = module.vpc.private_subnet_ids
}

#-------------ECR-----------------
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

#-------------EKS-----------------
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.node_role_arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}

#-------------Jenkins-----------------
output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

#-------------ArgoCD-----------------

output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = module.argo_cd.namespace
}

output "argocd_server_service" {
  description = "ArgoCD server service"
  value       = module.argo_cd.argo_cd_server_service
}

output "argocd_admin_password" {
  description = "Initial admin password"
  value       = module.argo_cd.admin_password
}
