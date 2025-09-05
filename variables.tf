variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "github_username" {
  description = "GitHub username"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t2.small"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "ecr-repo-django-app"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster-roman"
}
