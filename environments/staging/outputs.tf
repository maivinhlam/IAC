output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN"
  value       = module.compute.autoscaling_group_arn
}

output "security_group_id" {
  description = "Security group ID for web instances"
  value       = module.compute.security_group_id
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = var.create_database ? module.database[0].db_instance_endpoint : null
  sensitive   = true
}

output "database_port" {
  description = "RDS instance port"
  value       = var.create_database ? module.database[0].db_instance_port : null
}

output "database_name" {
  description = "Database name"
  value       = var.create_database ? module.database[0].db_instance_name : null
}

# Note: In staging, instances are in private subnets
output "instance_access_info" {
  description = "Information about accessing instances"
  value       = "Instances are deployed in private subnets. Use a bastion host or VPN for access."
}
