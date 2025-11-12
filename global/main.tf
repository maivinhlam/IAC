# Global Terraform configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Configure remote state storage
  # Uncomment and configure for your specific backend
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "global/terraform.tfstate"
  #   region         = "us-west-2"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "global"
      ManagedBy   = "terraform"
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    }
  }
}
