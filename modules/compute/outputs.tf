output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.main.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.main[0].name : null
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.main[0].arn : null
}

output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.main[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.main[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.main[*].private_ip
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_name
}
