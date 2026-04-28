terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  environment  = var.environment
}

# Security groups created FIRST — no dependencies on other modules
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
}

# Both database and compute take SG IDs from the security module
module "database" {
  source             = "./modules/database"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  mongodb_sg_id      = module.security.mongodb_sg_id
  redis_sg_id        = module.security.redis_sg_id
  db_username        = var.db_username
  db_password        = var.db_password
}

module "compute" {
  source             = "./modules/compute"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  backend_sg_id      = module.security.backend_sg_id
  mongodb_host       = module.database.mongodb_private_ip
  redis_host         = module.database.redis_endpoint
  db_username        = var.db_username
  db_password        = var.db_password
  jwt_secret         = var.jwt_secret
  cloudfront_url     = module.frontend.cloudfront_url
}

module "frontend" {
  source        = "./modules/frontend"
  project_name  = var.project_name
  environment   = var.environment
  alb_dns_name  = module.compute.alb_dns_name
}
