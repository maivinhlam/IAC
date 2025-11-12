variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID (leave empty for latest Amazon Linux)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = ""
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

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = false
}

variable "instance_count" {
  description = "Number of EC2 instances (when not using ASG)"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "target_group_arns" {
  description = "Target group ARNs for load balancer"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Health check type for ASG"
  type        = string
  default     = "EC2"
}

variable "root_volume_size" {
  description = "Size of root EBS volume in GB"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
