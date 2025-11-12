# General Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "iac-demo"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "staging-team"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.20.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# Compute Variables
variable "use_public_subnets" {
  description = "Deploy instances in public subnets"
  type        = bool
  default     = false  # Use private subnets in staging
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = true
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "create_key_pair" {
  description = "Create a new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Existing EC2 Key Pair name"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Terraform - Staging Environment</h1>" > /var/www/html/index.html
    echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
    echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
  EOF
}

# Database Variables
variable "create_database" {
  description = "Create RDS database"
  type        = bool
  default     = true
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "stagingapp"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "staging-secure-password-123!"
}

# Cognito Variables
variable "create_cognito" {
  description = "Create Cognito User Pool and related resources"
  type        = bool
  default     = true
}

variable "cognito_username_attributes" {
  description = "Whether email addresses or phone numbers can be specified as usernames"
  type        = list(string)
  default     = ["email"]
}

variable "cognito_auto_verified_attributes" {
  description = "Attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
}

variable "cognito_password_minimum_length" {
  description = "Minimum length of the password"
  type        = number
  default     = 10  # Stronger for staging
}

variable "cognito_password_require_lowercase" {
  description = "Whether to require lowercase letters in password"
  type        = bool
  default     = true
}

variable "cognito_password_require_numbers" {
  description = "Whether to require numbers in password"
  type        = bool
  default     = true
}

variable "cognito_password_require_symbols" {
  description = "Whether to require symbols in password"
  type        = bool
  default     = true
}

variable "cognito_password_require_uppercase" {
  description = "Whether to require uppercase letters in password"
  type        = bool
  default     = true
}

variable "cognito_mfa_configuration" {
  description = "Multi-factor authentication configuration"
  type        = string
  default     = "OPTIONAL"  # Optional MFA for staging
}

variable "cognito_generate_secret" {
  description = "Whether to generate a client secret"
  type        = bool
  default     = true  # More secure for staging
}

variable "cognito_explicit_auth_flows" {
  description = "List of authentication flows"
  type        = list(string)
  default     = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

variable "cognito_allowed_oauth_flows" {
  description = "List of allowed OAuth flows"
  type        = list(string)
  default     = ["code"]
}

variable "cognito_allowed_oauth_flows_user_pool_client" {
  description = "Whether the client is allowed to follow OAuth protocol"
  type        = bool
  default     = true
}

variable "cognito_allowed_oauth_scopes" {
  description = "List of allowed OAuth scopes"
  type        = list(string)
  default     = ["email", "openid", "profile"]
}

variable "cognito_callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
  default     = ["https://staging.example.com/auth/callback"]
}

variable "cognito_logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = ["https://staging.example.com"]
}

variable "cognito_domain" {
  description = "Domain for the Cognito hosted UI"
  type        = string
  default     = ""  # Set via tfvars
}

variable "cognito_create_identity_pool" {
  description = "Whether to create a Cognito Identity Pool"
  type        = bool
  default     = false
}

variable "cognito_allow_unauthenticated_identities" {
  description = "Whether to allow unauthenticated identities"
  type        = bool
  default     = false
}

variable "cognito_user_pool_groups" {
  description = "List of user pool groups to create"
  type = list(object({
    name        = string
    description = optional(string)
    precedence  = optional(number)
    role_arn    = optional(string)
  }))
  default = [
    {
      name        = "admin"
      description = "Administrator group"
      precedence  = 1
    },
    {
      name        = "manager"
      description = "Manager group"
      precedence  = 2
    },
    {
      name        = "user"
      description = "Regular user group"
      precedence  = 3
    }
  ]
}
