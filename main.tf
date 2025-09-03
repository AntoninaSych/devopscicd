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

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "lesson-7-terraform-state"
  table_name  = "lesson-7-terraform-locks"
  region      = var.region
}


module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = var.availability_zones

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}


module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson7-ecr"
  scan_on_push = true
}


module "eks" {
  source     = "./modules/eks"
  region     = var.region
  subnet_ids = module.vpc.public_subnets_ids
}


