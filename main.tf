# lesson-7/main.tf

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --- Backend for Terraform state (S3 + DynamoDB) ---
module "s3_backend" {
  source      = "./modules/s3-backend"
  region      = var.region
  bucket_name = "lesson7-tf-state"
  table_name  = "terraform-locks"
}

# --- VPC (module requires these exact variables) ---
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = "lesson7-vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  availability_zones = ["eu-west-2a", "eu-west-2b"]

  # Required by your module:
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
}

# --- ECR repository (module expects 'ecr_name') ---
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson7-ecr"
  scan_on_push = true
}

# --- EKS cluster and node group ---
# Workers in PUBLIC subnets to avoid NAT costs/timeouts
module "eks" {
  source     = "./modules/eks"
  region     = var.region
  subnet_ids = module.vpc.public_subnets_ids
}

# Outputs are defined in outputs.tf; do not duplicate here.
