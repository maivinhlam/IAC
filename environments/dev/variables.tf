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
  default     = "dev-team"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
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
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 1
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = false
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
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
    echo "<h1>Hello from Terraform - Development Environment</h1>" > /var/www/html/index.html
    echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
    echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
  EOF
}

# Database Variables
variable "create_database" {
  description = "Create RDS database"
  type        = bool
  default     = false
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
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "devapp"
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
  default     = "changeme123!"
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
  default     = 8
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
  default     = false  # Relaxed for dev
}

variable "cognito_password_require_uppercase" {
  description = "Whether to require uppercase letters in password"
  type        = bool
  default     = false  # Relaxed for dev
}

variable "cognito_generate_secret" {
  description = "Whether to generate a client secret"
  type        = bool
  default     = false  # For web apps, typically false
}

variable "cognito_explicit_auth_flows" {
  description = "List of authentication flows"
  type        = list(string)
  default     = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"  # For dev convenience
  ]
}

variable "cognito_allowed_oauth_flows" {
  description = "List of allowed OAuth flows"
  type        = list(string)
  default     = ["code", "implicit"]
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
  default     = ["http://localhost:3000/auth/callback"]
}

variable "cognito_logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

variable "cognito_domain" {
  description = "Domain for the Cognito hosted UI"
  type        = string
  default     = ""  # Leave empty for dev, can be set via tfvars
}

variable "cognito_create_identity_pool" {
  description = "Whether to create a Cognito Identity Pool"
  type        = bool
  default     = false  # Not needed for basic auth
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
      name        = "user"
      description = "Regular user group"
      precedence  = 2
    }
  ]
}

variable "cognito_schemas" {
  description = "List of schema attributes for the user pool"
  type = list(object({
    name                     = string
    attribute_data_type      = string
    developer_only_attribute = optional(bool, false)
    mutable                  = optional(bool, true)
    required                 = optional(bool, false)
    min_length              = optional(number)
    max_length              = optional(number)
    min_value               = optional(number)
    max_value               = optional(number)
  }))
  default = [
    {
      name                = "user_id"
      attribute_data_type = "String"
      mutable            = true
      required           = false
      min_length         = 1
      max_length         = 50
    }
  ]
}
