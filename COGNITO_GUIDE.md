# AWS Cognito Integration Guide

This guide explains how to use the Cognito module that has been integrated into your Infrastructure as Code (IAC) project.

## Overview

Amazon Cognito provides user identity and access management for your web and mobile applications. Our implementation includes:

- **User Pool**: Manages user registration, authentication, and user profiles
- **User Pool Client**: Configures how your application interacts with the user pool
- **Identity Pool**: (Optional) Provides AWS credentials for authenticated users
- **User Pool Groups**: Role-based access control
- **Hosted UI**: Ready-to-use login/signup pages
- **Custom Schemas**: Additional user attributes for business needs

## Environment Configurations

### Development Environment

- **Security Level**: Basic (relaxed for development)
- **Password Policy**: Minimum 8 characters, basic requirements
- **MFA**: Disabled
- **OAuth Flows**: Code, Implicit (for testing)
- **Advanced Security**: Disabled

### Staging Environment

- **Security Level**: Moderate (production-like)
- **Password Policy**: Minimum 10 characters, all requirements
- **MFA**: Optional
- **OAuth Flows**: Authorization Code only
- **Advanced Security**: Audit mode

### Production Environment

- **Security Level**: Maximum
- **Password Policy**: Minimum 12 characters, all requirements enforced
- **MFA**: Required
- **OAuth Flows**: Authorization Code only
- **Advanced Security**: Enforced
- **Custom Attributes**: Department, Employee ID

## Deployment

### 1. Enable Cognito in Your Environment

Edit your `terraform.tfvars` file:

```hcl
# Enable Cognito
create_cognito = true

# Configure domain (optional but recommended)
cognito_domain = "your-app-dev-auth"  # Must be globally unique

# Update callback URLs for your application
cognito_callback_urls = ["http://localhost:3000/auth/callback"]
cognito_logout_urls = ["http://localhost:3000"]
```

### 2. Deploy the Infrastructure

```bash
# Development
./scripts/deploy.sh dev plan
./scripts/deploy.sh dev apply

# Staging
./scripts/deploy.sh staging plan
./scripts/deploy.sh staging apply

# Production
./scripts/deploy.sh prod plan
./scripts/deploy.sh prod apply
```

### 3. Get Cognito Configuration

After deployment, retrieve the Cognito configuration:

```bash
# Get outputs
terraform output cognito_config
terraform output cognito_jwt_urls
terraform output cognito_hosted_ui_urls
```

## Application Integration

### Web Application (JavaScript/React/Vue)

#### 1. Install AWS Amplify (Recommended)

```bash
npm install aws-amplify
```

#### 2. Configure Amplify

```javascript
import { Amplify } from "aws-amplify";

const amplifyConfig = {
  Auth: {
    region: "us-west-2",
    userPoolId: "us-west-2_XXXXXXXXX", // From terraform output
    userPoolWebClientId: "XXXXXXXXXXXXXXXXXXXXXXXXXX", // From terraform output
    mandatorySignIn: true,
    signUpVerificationMethod: "code",
    oauth: {
      domain: "your-app-dev-auth.auth.us-west-2.amazoncognito.com",
      scope: ["email", "openid", "profile"],
      redirectSignIn: "http://localhost:3000/auth/callback",
      redirectSignOut: "http://localhost:3000",
      responseType: "code",
    },
  },
};

Amplify.configure(amplifyConfig);
```

#### 3. Authentication Functions

```javascript
import { Auth } from "aws-amplify";

// Sign up
const signUp = async (username, password, email) => {
  try {
    const { user } = await Auth.signUp({
      username,
      password,
      attributes: { email },
    });
    return user;
  } catch (error) {
    console.error("Error signing up:", error);
  }
};

// Sign in
const signIn = async (username, password) => {
  try {
    const user = await Auth.signIn(username, password);
    return user;
  } catch (error) {
    console.error("Error signing in:", error);
  }
};

// Sign out
const signOut = async () => {
  try {
    await Auth.signOut();
  } catch (error) {
    console.error("Error signing out:", error);
  }
};

// Get current user
const getCurrentUser = async () => {
  try {
    const user = await Auth.currentAuthenticatedUser();
    return user;
  } catch (error) {
    console.error("Not authenticated");
  }
};
```

### Backend Integration (Node.js/Python/Java)

#### Node.js Example

```javascript
const jwt = require("jsonwebtoken");
const jwksClient = require("jwks-rsa");

const client = jwksClient({
  jwksUri:
    "https://cognito-idp.us-west-2.amazonaws.com/us-west-2_XXXXXXXXX/.well-known/jwks.json",
});

const getKey = (header, callback) => {
  client.getSigningKey(header.kid, (err, key) => {
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
};

const verifyToken = (token) => {
  return new Promise((resolve, reject) => {
    jwt.verify(
      token,
      getKey,
      {
        issuer:
          "https://cognito-idp.us-west-2.amazonaws.com/us-west-2_XXXXXXXXX",
        algorithms: ["RS256"],
      },
      (err, decoded) => {
        if (err) reject(err);
        else resolve(decoded);
      }
    );
  });
};

// Express middleware
const authenticateToken = async (req, res, next) => {
  const token = req.headers.authorization?.replace("Bearer ", "");

  if (!token) {
    return res.status(401).json({ error: "Access token required" });
  }

  try {
    const decoded = await verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: "Invalid token" });
  }
};
```

### Mobile Applications

#### React Native with Amplify

```bash
npm install aws-amplify react-native-keychain
npx pod-install  # iOS only
```

```javascript
import { Auth } from "aws-amplify";
import { withAuthenticator } from "aws-amplify-react-native";

// Wrap your app
export default withAuthenticator(App);
```

## User Management

### Creating Users (Admin)

```javascript
import { Auth } from "aws-amplify";

const createUser = async (username, email, temporaryPassword) => {
  try {
    const user = await Auth.adminCreateUser({
      userPoolId: "us-west-2_XXXXXXXXX",
      username,
      userAttributes: [
        { Name: "email", Value: email },
        { Name: "email_verified", Value: "true" },
      ],
      temporaryPassword,
      messageAction: "SEND",
    });
    return user;
  } catch (error) {
    console.error("Error creating user:", error);
  }
};
```

### Adding Users to Groups

```bash
# Using AWS CLI
aws cognito-idp admin-add-user-to-group \
  --user-pool-id us-west-2_XXXXXXXXX \
  --username johndoe \
  --group-name admin
```

## Security Best Practices

### 1. Token Management

- Store tokens securely (use secure HTTP-only cookies for web)
- Implement token refresh logic
- Set appropriate token expiration times

### 2. Environment-Specific Security

- **Development**: Relaxed policies for ease of testing
- **Staging**: Production-like security for realistic testing
- **Production**: Maximum security settings enforced

### 3. MFA Implementation

```javascript
// Enable MFA for a user
const enableMFA = async () => {
  try {
    await Auth.setupTOTP(await Auth.currentAuthenticatedUser());
  } catch (error) {
    console.error("Error enabling MFA:", error);
  }
};
```

### 4. Custom Attributes (Production)

```javascript
// Update user with custom attributes
const updateUserAttributes = async (department, employeeId) => {
  try {
    await Auth.updateUserAttributes(await Auth.currentAuthenticatedUser(), {
      "custom:department": department,
      "custom:employee_id": employeeId,
    });
  } catch (error) {
    console.error("Error updating attributes:", error);
  }
};
```

## Monitoring and Analytics

### CloudWatch Integration

- Monitor sign-in attempts
- Track authentication failures
- Set up alarms for suspicious activities

### Custom Analytics

```javascript
// Track authentication events
import { Analytics } from "aws-amplify";

Analytics.record({
  name: "userSignIn",
  attributes: {
    username: user.username,
    signInMethod: "password",
  },
});
```

## Troubleshooting

### Common Issues

1. **Domain Already Exists**

   ```
   Error: Domain already exists
   Solution: Choose a unique domain name in terraform.tfvars
   ```

2. **Callback URL Mismatch**

   ```
   Error: redirect_mismatch
   Solution: Ensure callback URLs match in both Cognito config and your app
   ```

3. **Token Verification Failed**
   ```
   Solution: Verify the correct User Pool ID and region in your JWT validation
   ```

### Debugging

```javascript
// Enable Amplify debugging
import { Amplify } from "aws-amplify";

Amplify.configure({
  ...config,
  Analytics: {
    disabled: false,
  },
});

// Set log level
Amplify.Logger.LOG_LEVEL = "DEBUG";
```

## Cost Optimization

- **Free Tier**: 50,000 MAUs (Monthly Active Users)
- **Pay-as-you-scale**: $0.0055 per MAU after free tier
- **Advanced Security**: Additional $0.05 per MAU
- **SMS MFA**: $0.50 per SMS message

## Next Steps

1. **Customize the UI**: Use the hosted UI or build custom authentication flows
2. **Integrate with APIs**: Use JWT tokens to secure your API endpoints
3. **Add Social Providers**: Configure Google, Facebook, or other OAuth providers
4. **Implement Fine-grained Permissions**: Use groups and custom claims for authorization
5. **Set up Monitoring**: Configure CloudWatch dashboards and alarms

For more advanced configurations, refer to the [AWS Cognito documentation](https://docs.aws.amazon.com/cognito/).
