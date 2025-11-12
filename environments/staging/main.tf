# Staging Environment Configuration
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
  #   key            = "environments/staging/terraform.tfstate"
  #   region         = "us-west-2"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "staging"
      Project     = var.project_name
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

# Local values
locals {
  name_prefix = "${var.project_name}-staging"
  
  common_tags = {
    Environment = "staging"
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
  subnet_ids       = var.use_public_subnets ? module.vpc.public_subnet_ids : module.vpc.private_subnet_ids

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

  backup_retention_period = 7     # Weekly backups for staging
  multi_az               = false  # Single AZ for staging
  deletion_protection    = false  # Allow deletion in staging
  skip_final_snapshot    = false  # Keep snapshot in staging

  tags = local.common_tags
}

# Cognito Module (Authentication)
module "cognito" {
  count  = var.create_cognito ? 1 : 0
  source = "../../modules/cognito"

  name = local.name_prefix

  # Basic Configuration
  username_attributes         = var.cognito_username_attributes
  auto_verified_attributes   = var.cognito_auto_verified_attributes
  
  # Password Policy (moderate for staging)
  password_minimum_length     = var.cognito_password_minimum_length
  password_require_lowercase  = var.cognito_password_require_lowercase
  password_require_numbers    = var.cognito_password_require_numbers
  password_require_symbols    = var.cognito_password_require_symbols
  password_require_uppercase  = var.cognito_password_require_uppercase

  # Security Configuration
  advanced_security_mode = "AUDIT"  # Enable security monitoring
  mfa_configuration     = var.cognito_mfa_configuration

  # Client Configuration
  generate_secret            = var.cognito_generate_secret
  explicit_auth_flows        = var.cognito_explicit_auth_flows
  
  # OAuth Configuration
  allowed_oauth_flows                  = var.cognito_allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = var.cognito_allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = var.cognito_allowed_oauth_scopes
  callback_urls                        = var.cognito_callback_urls
  logout_urls                          = var.cognito_logout_urls

  # Domain Configuration
  domain = var.cognito_domain

  # Identity Pool
  create_identity_pool              = var.cognito_create_identity_pool
  allow_unauthenticated_identities = var.cognito_allow_unauthenticated_identities

  # User Pool Groups
  user_pool_groups = var.cognito_user_pool_groups

  tags = local.common_tags
}
