# Cognito Module - User Authentication and Authorization
resource "aws_cognito_user_pool" "main" {
  name = "${var.name}-user-pool"

  # User attributes
  alias_attributes = var.alias_attributes
  username_attributes = var.username_attributes

  # Password policy
  password_policy {
    minimum_length    = var.password_minimum_length
    require_lowercase = var.password_require_lowercase
    require_numbers   = var.password_require_numbers
    require_symbols   = var.password_require_symbols
    require_uppercase = var.password_require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # Email configuration
  dynamic "email_configuration" {
    for_each = var.email_sending_account != "" ? [1] : []
    content {
      email_sending_account = var.email_sending_account
      from_email_address    = var.from_email_address
      reply_to_email_address = var.reply_to_email_address
      source_arn           = var.ses_source_arn
    }
  }

  # SMS configuration
  dynamic "sms_configuration" {
    for_each = var.sms_authentication_message != "" ? [1] : []
    content {
      external_id    = "${var.name}-external-id"
      sns_caller_arn = aws_iam_role.cognito_sms[0].arn
    }
  }

  # Account recovery
  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = var.recovery_mechanisms
      content {
        name     = recovery_mechanism.value.name
        priority = recovery_mechanism.value.priority
      }
    }
  }

  # Admin create user config
  admin_create_user_config {
    allow_admin_create_user_only = var.allow_admin_create_user_only
    
    dynamic "invite_message_template" {
      for_each = var.invite_message_template != null ? [var.invite_message_template] : []
      content {
        email_message = invite_message_template.value.email_message
        email_subject = invite_message_template.value.email_subject
        sms_message   = invite_message_template.value.sms_message
      }
    }
  }

  # Auto verified attributes
  auto_verified_attributes = var.auto_verified_attributes

  # Verification message template
  dynamic "verification_message_template" {
    for_each = var.verification_message_template != null ? [var.verification_message_template] : []
    content {
      default_email_option = verification_message_template.value.default_email_option
      email_message        = verification_message_template.value.email_message
      email_subject        = verification_message_template.value.email_subject
      sms_message          = verification_message_template.value.sms_message
    }
  }

  # User attribute update settings
  user_attribute_update_settings {
    attributes_require_verification_before_update = var.attributes_require_verification_before_update
  }

  # Device configuration
  device_configuration {
    challenge_required_on_new_device      = var.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_only_remembered_on_user_prompt
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration != "OFF" ? [1] : []
    content {
      enabled = var.software_token_mfa_enabled
    }
  }

  # Lambda triggers
  dynamic "lambda_config" {
    for_each = length(var.lambda_triggers) > 0 ? [1] : []
    content {
      create_auth_challenge          = lookup(var.lambda_triggers, "create_auth_challenge", null)
      custom_message                = lookup(var.lambda_triggers, "custom_message", null)
      define_auth_challenge         = lookup(var.lambda_triggers, "define_auth_challenge", null)
      post_authentication          = lookup(var.lambda_triggers, "post_authentication", null)
      post_confirmation            = lookup(var.lambda_triggers, "post_confirmation", null)
      pre_authentication           = lookup(var.lambda_triggers, "pre_authentication", null)
      pre_sign_up                  = lookup(var.lambda_triggers, "pre_sign_up", null)
      pre_token_generation         = lookup(var.lambda_triggers, "pre_token_generation", null)
      user_migration               = lookup(var.lambda_triggers, "user_migration", null)
      verify_auth_challenge_response = lookup(var.lambda_triggers, "verify_auth_challenge_response", null)
    }
  }

  # Schema (user attributes)
  dynamic "schema" {
    for_each = var.schemas
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = lookup(schema.value, "developer_only_attribute", false)
      mutable                  = lookup(schema.value, "mutable", true)
      required                 = lookup(schema.value, "required", false)

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [schema.value] : []
        content {
          min_length = lookup(string_attribute_constraints.value, "min_length", null)
          max_length = lookup(string_attribute_constraints.value, "max_length", null)
        }
      }

      dynamic "number_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "Number" ? [schema.value] : []
        content {
          min_value = lookup(number_attribute_constraints.value, "min_value", null)
          max_value = lookup(number_attribute_constraints.value, "max_value", null)
        }
      }
    }
  }

  tags = var.tags
}

# User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  count = var.domain != "" ? 1 : 0

  domain       = var.domain
  user_pool_id = aws_cognito_user_pool.main.id
  certificate_arn = var.certificate_arn

  tags = var.tags
}

# User Pool Client
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.name}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Client settings
  generate_secret                      = var.generate_secret
  refresh_token_validity               = var.refresh_token_validity
  access_token_validity                = var.access_token_validity
  id_token_validity                    = var.id_token_validity
  token_validity_units {
    access_token  = var.access_token_validity_units
    id_token      = var.id_token_validity_units
    refresh_token = var.refresh_token_validity_units
  }

  # Flows
  explicit_auth_flows = var.explicit_auth_flows

  # OAuth settings
  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  default_redirect_uri                 = var.default_redirect_uri

  # Read and write attributes
  read_attributes  = var.read_attributes
  write_attributes = var.write_attributes

  # Prevent user existence errors
  prevent_user_existence_errors = var.prevent_user_existence_errors

  # Supported identity providers
  supported_identity_providers = var.supported_identity_providers

  # Analytics configuration
  dynamic "analytics_configuration" {
    for_each = var.analytics_configuration != null ? [var.analytics_configuration] : []
    content {
      application_arn  = analytics_configuration.value.application_arn
      application_id   = analytics_configuration.value.application_id
      external_id      = analytics_configuration.value.external_id
      role_arn        = analytics_configuration.value.role_arn
      user_data_shared = analytics_configuration.value.user_data_shared
    }
  }

  depends_on = [aws_cognito_user_pool.main]
}

# Identity Pool
resource "aws_cognito_identity_pool" "main" {
  count = var.create_identity_pool ? 1 : 0

  identity_pool_name               = "${var.name}-identity-pool"
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
  allow_classic_flow              = var.allow_classic_flow

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.main.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }

  # Supported login providers
  dynamic "supported_login_providers" {
    for_each = var.supported_login_providers
    content {
      key   = supported_login_providers.key
      value = supported_login_providers.value
    }
  }

  # SAML providers
  saml_provider_arns = var.saml_provider_arns

  # OpenID Connect providers
  openid_connect_provider_arns = var.openid_connect_provider_arns

  tags = var.tags
}

# IAM Role for SMS
resource "aws_iam_role" "cognito_sms" {
  count = var.sms_authentication_message != "" ? 1 : 0

  name = "${var.name}-cognito-sms-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cognito-idp.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "${var.name}-external-id"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cognito_sms" {
  count = var.sms_authentication_message != "" ? 1 : 0

  name = "${var.name}-cognito-sms-policy"
  role = aws_iam_role.cognito_sms[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Roles for Identity Pool
resource "aws_iam_role" "authenticated" {
  count = var.create_identity_pool ? 1 : 0

  name = "${var.name}-cognito-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role" "unauthenticated" {
  count = var.create_identity_pool && var.allow_unauthenticated_identities ? 1 : 0

  name = "${var.name}-cognito-unauthenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policies to authenticated role
resource "aws_iam_role_policy" "authenticated" {
  count = var.create_identity_pool ? 1 : 0

  name = "${var.name}-authenticated-policy"
  role = aws_iam_role.authenticated[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.authenticated_role_policy_statements
  })
}

# Attach policies to unauthenticated role
resource "aws_iam_role_policy" "unauthenticated" {
  count = var.create_identity_pool && var.allow_unauthenticated_identities ? 1 : 0

  name = "${var.name}-unauthenticated-policy"
  role = aws_iam_role.unauthenticated[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.unauthenticated_role_policy_statements
  })
}

# Identity Pool Role Attachment
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  count = var.create_identity_pool ? 1 : 0

  identity_pool_id = aws_cognito_identity_pool.main[0].id

  roles = merge(
    {
      "authenticated" = aws_iam_role.authenticated[0].arn
    },
    var.allow_unauthenticated_identities ? {
      "unauthenticated" = aws_iam_role.unauthenticated[0].arn
    } : {}
  )

  dynamic "role_mapping" {
    for_each = var.role_mappings
    content {
      identity_provider         = role_mapping.value.identity_provider
      ambiguous_role_resolution = lookup(role_mapping.value, "ambiguous_role_resolution", null)
      type                     = role_mapping.value.type

      dynamic "mapping_rule" {
        for_each = lookup(role_mapping.value, "mapping_rules", [])
        content {
          claim      = mapping_rule.value.claim
          match_type = mapping_rule.value.match_type
          role_arn   = mapping_rule.value.role_arn
          value      = mapping_rule.value.value
        }
      }
    }
  }
}

# User Pool Groups
resource "aws_cognito_user_pool_group" "groups" {
  for_each = { for group in var.user_pool_groups : group.name => group }

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.main.id
  description  = lookup(each.value, "description", null)
  precedence   = lookup(each.value, "precedence", null)
  role_arn     = lookup(each.value, "role_arn", null)
}
