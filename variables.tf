variable "region" {
  type        = string
  description = "AWS region for all resources"
  default     = "eu-west-2"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for VPC"
  default     = "lesson7-vpc"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs used for subnets"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets CIDRs"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}
