variable "region" {
  description = "AWS region"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the EKS cluster"
  type        = list(string)
}
