# User Pool Outputs
output "user_pool_id" {
  description = "ID of the user pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the user pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint name of the user pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "user_pool_domain" {
  description = "Domain of the user pool"
  value       = var.domain != "" ? aws_cognito_user_pool_domain.main[0].domain : null
}

output "user_pool_domain_cloudfront_distribution" {
  description = "CloudFront distribution ARN of the domain"
  value       = var.domain != "" ? aws_cognito_user_pool_domain.main[0].cloudfront_distribution_arn : null
}

# User Pool Client Outputs
output "user_pool_client_id" {
  description = "ID of the user pool client"
  value       = aws_cognito_user_pool_client.main.id
}

output "user_pool_client_secret" {
  description = "Secret of the user pool client"
  value       = aws_cognito_user_pool_client.main.client_secret
  sensitive   = true
}

# Identity Pool Outputs
output "identity_pool_id" {
  description = "ID of the identity pool"
  value       = var.create_identity_pool ? aws_cognito_identity_pool.main[0].id : null
}

output "identity_pool_arn" {
  description = "ARN of the identity pool"
  value       = var.create_identity_pool ? aws_cognito_identity_pool.main[0].arn : null
}

# IAM Role Outputs
output "authenticated_role_arn" {
  description = "ARN of the authenticated role"
  value       = var.create_identity_pool ? aws_iam_role.authenticated[0].arn : null
}

output "unauthenticated_role_arn" {
  description = "ARN of the unauthenticated role"
  value       = var.create_identity_pool && var.allow_unauthenticated_identities ? aws_iam_role.unauthenticated[0].arn : null
}

# User Pool Groups
output "user_pool_group_names" {
  description = "Names of the user pool groups"
  value       = [for group in aws_cognito_user_pool_group.groups : group.name]
}

# Configuration Outputs for Client Applications
output "cognito_config" {
  description = "Cognito configuration for client applications"
  value = {
    region           = data.aws_region.current.name
    user_pool_id     = aws_cognito_user_pool.main.id
    client_id        = aws_cognito_user_pool_client.main.id
    identity_pool_id = var.create_identity_pool ? aws_cognito_identity_pool.main[0].id : null
    domain          = var.domain != "" ? aws_cognito_user_pool_domain.main[0].domain : null
  }
}

# JWT Token URLs
output "jwt_token_urls" {
  description = "JWT token validation URLs"
  value = {
    jwks_uri = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/jwks.json"
    issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

# Hosted UI URLs
output "hosted_ui_urls" {
  description = "Hosted UI URLs for authentication flows"
  value = var.domain != "" ? {
    login_url = "https://${aws_cognito_user_pool_domain.main[0].domain}/login?client_id=${aws_cognito_user_pool_client.main.id}&response_type=code&scope=email+openid+phone+profile&redirect_uri=${length(var.callback_urls) > 0 ? var.callback_urls[0] : ""}"
    logout_url = "https://${aws_cognito_user_pool_domain.main[0].domain}/logout?client_id=${aws_cognito_user_pool_client.main.id}&logout_uri=${length(var.logout_urls) > 0 ? var.logout_urls[0] : ""}"
    signup_url = "https://${aws_cognito_user_pool_domain.main[0].domain}/signup?client_id=${aws_cognito_user_pool_client.main.id}&response_type=code&scope=email+openid+phone+profile&redirect_uri=${length(var.callback_urls) > 0 ? var.callback_urls[0] : ""}"
  } : null
}

# Data sources
data "aws_region" "current" {}
