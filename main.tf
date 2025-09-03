terraform {
  # Allow aws provider 5.x and 6.x
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

# Pin region to eu-west-2 to keep AZs consistent
provider "aws" {
  region = "eu-west-2"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "lesson7-tf-state"    # NOTE: bucket name must be globally unique; change if already taken
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  vpc_name           = "lesson7-vpc"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
  # Use AZs that belong to the selected region (eu-west-2)
  availability_zones = ["eu-west-2a", "eu-west-2b"]
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson7-ecr"
  scan_on_push = true
}

module "eks" {
  source     = "./modules/eks"
  subnet_ids = module.vpc.private_subnets_ids
}
