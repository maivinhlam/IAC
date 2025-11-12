# Production Environment Configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "environments/prod/terraform.tfstate"
  #   region         = "us-west-2"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "production"
      Project     = var.project_name
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

# Local values
locals {
  name_prefix = "${var.project_name}-prod"
  
  common_tags = {
    Environment = "production"
    Project     = var.project_name
    Owner       = var.owner
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway

  tags = local.common_tags
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  name             = local.name_prefix
  vpc_id           = module.vpc.vpc_id
  vpc_cidr_block   = module.vpc.vpc_cidr_block
  subnet_ids       = module.vpc.private_subnet_ids  # Use private subnets in production

  instance_type        = var.instance_type
  instance_count       = var.instance_count
  enable_auto_scaling  = var.enable_auto_scaling
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  create_key_pair = var.create_key_pair
  public_key     = var.public_key
  key_name       = var.key_name

  user_data = var.user_data

  tags = local.common_tags
}

# Database Module
module "database" {
  count  = var.create_database ? 1 : 0
  source = "../../modules/database"

  name       = local.name_prefix
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  engine               = var.db_engine
  engine_version      = var.db_engine_version
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  database_name       = var.db_name
  username            = var.db_username
  password            = var.db_password

  allowed_security_groups = [module.compute.security_group_id]

  backup_retention_period = 30    # 30 days for production
  multi_az               = true   # Multi-AZ for production
  deletion_protection    = true   # Protect from deletion
  skip_final_snapshot    = false  # Always take final snapshot

  # Enable enhanced monitoring and performance insights for production
  monitoring_interval             = 60
  performance_insights_enabled    = true
  performance_insights_retention_period = 7

  # Create read replica for production
  create_read_replica = var.create_read_replica

  tags = local.common_tags
}
