terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
  backend "s3" {
    bucket         = "lojaveloz-terraform-state"
    key            = "cluster.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "lojaveloz-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  name                 = "lojaveloz-${var.environment}"
  cidr                 = var.vpc_cidr
  azs                  = var.availability_zones
  private_subnets      = var.private_subnet_cidrs
  public_subnets       = var.public_subnet_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "production"
}

module "eks" {
  source = "./modules/eks"

  name               = "lojaveloz-${var.environment}"
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids

  node_groups = {
    general = {
      instance_types = [var.node_instance_type]
      min_size       = var.min_nodes
      max_size       = var.max_nodes
      desired_size   = var.desired_nodes
      labels         = { role = "general" }
    }
  }

  cluster_addons = {
    kube-proxy         = {}
    vpc-cni            = {}
    coredns            = {}
    aws-ebs-csi-driver = {}
  }
}

module "rds" {
  source = "./modules/rds"

  name                    = "lojaveloz-${var.environment}"
  engine                  = "postgres"
  engine_version          = "16.2"
  instance_class          = var.db_instance_class
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  allowed_cidr_blocks     = [var.vpc_cidr]
  multi_az                = var.environment == "production"
  deletion_protection     = var.environment == "production"
  backup_retention_period = var.environment == "production" ? 30 : 7
}
