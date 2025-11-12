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

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = module.compute.instance_ids
}

output "instance_public_ips" {
  description = "EC2 instance public IP addresses"
  value       = module.compute.instance_public_ips
}

output "instance_private_ips" {
  description = "EC2 instance private IP addresses"
  value       = module.compute.instance_private_ips
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

# Connection information
output "ssh_connection" {
  description = "SSH connection command"
  value       = length(module.compute.instance_public_ips) > 0 ? "ssh -i ~/.ssh/your-key.pem ec2-user@${module.compute.instance_public_ips[0]}" : "No public IPs available"
}

output "web_url" {
  description = "Web application URL"
  value       = length(module.compute.instance_public_ips) > 0 ? "http://${module.compute.instance_public_ips[0]}" : "No public IPs available"
}
