variable "kubeconfig" {
  description = "Шлях до kubeconfig файлу"
  type        = string
}

variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN OIDC провайдера для IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL OIDC провайдера для IRSA"
  type        = string
}

variable "github_username" {
  description = "GitHub username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}
