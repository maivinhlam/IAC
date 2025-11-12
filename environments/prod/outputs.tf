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

output "read_replica_endpoint" {
  description = "Read replica endpoint"
  value       = var.create_database && var.create_read_replica ? module.database[0].read_replica_endpoint : null
  sensitive   = true
}

# Production instances are in private subnets for security
output "instance_access_info" {
  description = "Information about accessing instances"
  value       = "Production instances are deployed in private subnets for security. Use a bastion host, VPN, or AWS Systems Manager Session Manager for access."
}

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = var.create_cognito ? module.cognito[0].user_pool_id : null
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = var.create_cognito ? module.cognito[0].user_pool_client_id : null
}

output "cognito_user_pool_domain" {
  description = "Cognito User Pool Domain"
  value       = var.create_cognito ? module.cognito[0].user_pool_domain : null
}

output "cognito_config" {
  description = "Cognito configuration for client applications"
  value       = var.create_cognito ? module.cognito[0].cognito_config : null
}

output "cognito_jwt_urls" {
  description = "Cognito JWT token URLs for validation"
  value       = var.create_cognito ? module.cognito[0].jwt_token_urls : null
}

output "cognito_hosted_ui_urls" {
  description = "Cognito Hosted UI URLs"
  value       = var.create_cognito ? module.cognito[0].hosted_ui_urls : null
}

output "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = var.create_cognito ? module.cognito[0].identity_pool_id : null
}

output "cognito_authenticated_role_arn" {
  description = "ARN of the authenticated IAM role"
  value       = var.create_cognito ? module.cognito[0].authenticated_role_arn : null
}
