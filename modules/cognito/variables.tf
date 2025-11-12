variable "name" {
  description = "Name prefix for Cognito resources"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# User Pool Configuration
variable "alias_attributes" {
  description = "Attributes supported as an alias for this user pool"
  type        = list(string)
  default     = []
}

variable "username_attributes" {
  description = "Whether email addresses or phone numbers can be specified as usernames when a user signs up"
  type        = list(string)
  default     = ["email"]
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
}

variable "attributes_require_verification_before_update" {
  description = "A list of attributes requiring verification before update"
  type        = list(string)
  default     = ["email"]
}

# Password Policy
variable "password_minimum_length" {
  description = "Minimum length of the password policy"
  type        = number
  default     = 8
}

variable "password_require_lowercase" {
  description = "Whether you have required users to use at least one lowercase letter in their password"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Whether you have required users to use at least one number in their password"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Whether you have required users to use at least one symbol in their password"
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Whether you have required users to use at least one uppercase letter in their password"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Number of days a temporary password is valid"
  type        = number
  default     = 7
}

# Security Configuration
variable "advanced_security_mode" {
  description = "Mode for advanced security features"
  type        = string
  default     = "OFF"
  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED."
  }
}

variable "mfa_configuration" {
  description = "Multi-factor authentication configuration"
  type        = string
  default     = "OFF"
  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, ON, or OPTIONAL."
  }
}

variable "software_token_mfa_enabled" {
  description = "Whether software token MFA is enabled"
  type        = bool
  default     = false
}

# Email Configuration
variable "email_sending_account" {
  description = "Email delivery method"
  type        = string
  default     = "COGNITO_DEFAULT"
  validation {
    condition     = contains(["COGNITO_DEFAULT", "DEVELOPER"], var.email_sending_account)
    error_message = "Email sending account must be COGNITO_DEFAULT or DEVELOPER."
  }
}

variable "from_email_address" {
  description = "Sender's email address or sender's display name with their email address"
  type        = string
  default     = ""
}

variable "reply_to_email_address" {
  description = "Reply-to email address"
  type        = string
  default     = ""
}

variable "ses_source_arn" {
  description = "ARN of a verified email address in Amazon SES"
  type        = string
  default     = ""
}

# SMS Configuration
variable "sms_authentication_message" {
  description = "String representing the SMS authentication message"
  type        = string
  default     = ""
}

# Admin Configuration
variable "allow_admin_create_user_only" {
  description = "Set to True if only the administrator is allowed to create user profiles"
  type        = bool
  default     = false
}

variable "invite_message_template" {
  description = "Invite message template structure"
  type = object({
    email_message = string
    email_subject = string
    sms_message   = string
  })
  default = null
}

variable "verification_message_template" {
  description = "Verification message template structure"
  type = object({
    default_email_option = string
    email_message        = string
    email_subject        = string
    sms_message          = string
  })
  default = null
}

# Device Configuration
variable "challenge_required_on_new_device" {
  description = "Whether a challenge is required on a new device"
  type        = bool
  default     = false
}

variable "device_only_remembered_on_user_prompt" {
  description = "Whether a device is only remembered on user prompt"
  type        = bool
  default     = false
}

# Recovery Configuration
variable "recovery_mechanisms" {
  description = "List of recovery mechanisms"
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]
}

# Lambda Triggers
variable "lambda_triggers" {
  description = "Lambda trigger configuration"
  type        = map(string)
  default     = {}
}

# Schema Configuration
variable "schemas" {
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

# Domain Configuration
variable "domain" {
  description = "Domain for the user pool"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of an ISSUED ACM certificate for a custom domain"
  type        = string
  default     = ""
}

# Client Configuration
variable "generate_secret" {
  description = "Whether to generate a client secret"
  type        = bool
  default     = false
}

variable "refresh_token_validity" {
  description = "Time limit in days refresh tokens are valid for"
  type        = number
  default     = 30
}

variable "access_token_validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the access token is no longer valid"
  type        = number
  default     = 60
}

variable "id_token_validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid"
  type        = number
  default     = 60
}

variable "access_token_validity_units" {
  description = "Time unit for access token validity"
  type        = string
  default     = "minutes"
}

variable "id_token_validity_units" {
  description = "Time unit for ID token validity"
  type        = string
  default     = "minutes"
}

variable "refresh_token_validity_units" {
  description = "Time unit for refresh token validity"
  type        = string
  default     = "days"
}

variable "explicit_auth_flows" {
  description = "List of authentication flows"
  type        = list(string)
  default     = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# OAuth Configuration
variable "allowed_oauth_flows" {
  description = "List of allowed OAuth flows"
  type        = list(string)
  default     = []
}

variable "allowed_oauth_flows_user_pool_client" {
  description = "Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools"
  type        = bool
  default     = false
}

variable "allowed_oauth_scopes" {
  description = "List of allowed OAuth scopes"
  type        = list(string)
  default     = []
}

variable "callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = []
}

variable "default_redirect_uri" {
  description = "Default redirect URI"
  type        = string
  default     = ""
}

variable "read_attributes" {
  description = "List of user pool attributes the application client can read from"
  type        = list(string)
  default     = []
}

variable "write_attributes" {
  description = "List of user pool attributes the application client can write to"
  type        = list(string)
  default     = []
}

variable "prevent_user_existence_errors" {
  description = "Choose which errors and responses are returned by Cognito APIs during authentication"
  type        = string
  default     = "ENABLED"
}

variable "supported_identity_providers" {
  description = "List of provider names for the identity providers"
  type        = list(string)
  default     = ["COGNITO"]
}

# Analytics Configuration
variable "analytics_configuration" {
  description = "Configuration block for Amazon Pinpoint analytics"
  type = object({
    application_arn  = string
    application_id   = string
    external_id      = string
    role_arn        = string
    user_data_shared = bool
  })
  default = null
}

# Identity Pool Configuration
variable "create_identity_pool" {
  description = "Whether to create a Cognito Identity Pool"
  type        = bool
  default     = false
}

variable "allow_unauthenticated_identities" {
  description = "Whether the identity pool supports unauthenticated logins or not"
  type        = bool
  default     = false
}

variable "allow_classic_flow" {
  description = "Whether the classic flow is enabled"
  type        = bool
  default     = false
}

variable "supported_login_providers" {
  description = "Key-value pairs mapping provider names to provider app IDs"
  type        = map(string)
  default     = {}
}

variable "saml_provider_arns" {
  description = "List of ARNs of SAML provider"
  type        = list(string)
  default     = []
}

variable "openid_connect_provider_arns" {
  description = "List of ARNs of OpenID Connect providers"
  type        = list(string)
  default     = []
}

# IAM Role Policies
variable "authenticated_role_policy_statements" {
  description = "IAM policy statements for authenticated role"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = [
    {
      Effect = "Allow"
      Action = [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ]
      Resource = ["*"]
    }
  ]
}

variable "unauthenticated_role_policy_statements" {
  description = "IAM policy statements for unauthenticated role"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = [
    {
      Effect = "Allow"
      Action = [
        "mobileanalytics:PutEvents",
        "cognito-sync:*"
      ]
      Resource = ["*"]
    }
  ]
}

# Role Mapping
variable "role_mappings" {
  description = "List of role mapping configurations"
  type = list(object({
    identity_provider         = string
    ambiguous_role_resolution = optional(string)
    type                     = string
    mapping_rules = optional(list(object({
      claim      = string
      match_type = string
      role_arn   = string
      value      = string
    })), [])
  }))
  default = []
}

# User Pool Groups
variable "user_pool_groups" {
  description = "List of user pool groups to create"
  type = list(object({
    name        = string
    description = optional(string)
    precedence  = optional(number)
    role_arn    = optional(string)
  }))
  default = []
}
