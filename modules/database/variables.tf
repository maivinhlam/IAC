variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["mysql", "postgres", "mariadb", "oracle-ee", "oracle-se2", "oracle-se1", "oracle-se", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"], var.engine)
    error_message = "Engine must be one of: mysql, postgres, mariadb, oracle-ee, oracle-se2, oracle-se1, oracle-se, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "major_engine_version" {
  description = "Major engine version for option group"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp2"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS Key ID for encryption"
  type        = string
  default     = ""
}

variable "database_name" {
  description = "Name of the initial database"
  type        = string
  default     = "myapp"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "publicly_accessible" {
  description = "Make instance publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "create_read_replica" {
  description = "Create a read replica"
  type        = bool
  default     = false
}

variable "read_replica_instance_class" {
  description = "Instance class for read replica"
  type        = string
  default     = ""
}

variable "parameter_group_family" {
  description = "Parameter group family"
  type        = string
  default     = "mysql8.0"
}

variable "parameters" {
  description = "Database parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "options" {
  description = "Database options"
  type = list(object({
    option_name = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

variable "allowed_security_groups" {
  description = "Security groups allowed to access the database"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
