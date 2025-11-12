# 🆔 Cognito Custom User ID Configuration Guide

Your Cognito User Pool has been configured with:

- **Email-based login** (`username_attributes = ["email"]`)
- **Custom attribute**: `custom:user_id` (String, 1-50 characters)

## ✅ **Configuration Details:**

### **Login Method**

- Users can sign up and sign in using their **email address**
- Email verification is automatically enabled
- Password requirements are configurable per environment

### **Custom User ID Attribute**

- **Name**: `custom:user_id`
- **Type**: String
- **Length**: 1-50 characters
- **Mutable**: Yes (can be updated after creation)
- **Required**: No (optional attribute)

## 🔧 **Usage Examples:**

### **1. JavaScript/React (AWS Amplify)**

#### Sign Up with Custom User ID:

```javascript
import { Auth } from "aws-amplify";

// Sign up user with custom user_id
const signUpUser = async () => {
  try {
    const { user } = await Auth.signUp({
      username: "user@example.com",
      password: "SecurePassword123!",
      attributes: {
        email: "user@example.com",
        "custom:user_id": "USR001", // Custom user ID
      },
    });
    console.log("User signed up:", user);
  } catch (error) {
    console.error("Error signing up:", error);
  }
};
```

#### Update Custom User ID:

```javascript
import { Auth } from "aws-amplify";

const updateUserID = async () => {
  try {
    const user = await Auth.currentAuthenticatedUser();
    const result = await Auth.updateUserAttributes(user, {
      "custom:user_id": "USR002", // Update user ID
    });
    console.log("User ID updated:", result);
  } catch (error) {
    console.error("Error updating user ID:", error);
  }
};
```

#### Get User Attributes:

```javascript
import { Auth } from "aws-amplify";

const getUserInfo = async () => {
  try {
    const user = await Auth.currentAuthenticatedUser();
    const attributes = await Auth.userAttributes(user);

    const userIdAttr = attributes.find(
      (attr) => attr.Name === "custom:user_id"
    );
    console.log("User ID:", userIdAttr ? userIdAttr.Value : "Not set");
  } catch (error) {
    console.error("Error getting user info:", error);
  }
};
```

### **2. Node.js Backend (AWS SDK)**

#### Create User with Custom ID (Admin):

```javascript
const AWS = require("aws-sdk");
const cognito = new AWS.CognitoIdentityServiceProvider();

const createUser = async () => {
  const params = {
    UserPoolId: "us-west-2_XXXXXXXXX",
    Username: "user@example.com",
    UserAttributes: [
      {
        Name: "email",
        Value: "user@example.com",
      },
      {
        Name: "custom:user_id",
        Value: "USR003",
      },
    ],
    TemporaryPassword: "TempPass123!",
    MessageAction: "SUPPRESS", // Don't send welcome email
  };

  try {
    const result = await cognito.adminCreateUser(params).promise();
    console.log("User created:", result.User.Username);
  } catch (error) {
    console.error("Error creating user:", error);
  }
};
```

#### Get User by Custom ID:

```javascript
const AWS = require("aws-sdk");
const cognito = new AWS.CognitoIdentityServiceProvider();

const getUserByCustomId = async (customUserId) => {
  const params = {
    UserPoolId: "us-west-2_XXXXXXXXX",
    Filter: `custom:user_id = "${customUserId}"`,
    Limit: 1,
  };

  try {
    const result = await cognito.listUsers(params).promise();
    return result.Users[0] || null;
  } catch (error) {
    console.error("Error finding user:", error);
    return null;
  }
};
```

### **3. Python (Boto3)**

#### Create User with Custom ID:

```python
import boto3

cognito = boto3.client('cognito-idp')

def create_user_with_custom_id(email, custom_user_id):
    try:
        response = cognito.admin_create_user(
            UserPoolId='us-west-2_XXXXXXXXX',
            Username=email,
            UserAttributes=[
                {
                    'Name': 'email',
                    'Value': email
                },
                {
                    'Name': 'custom:user_id',
                    'Value': custom_user_id
                }
            ],
            TemporaryPassword='TempPass123!',
            MessageAction='SUPPRESS'
        )
        print(f"User created: {response['User']['Username']}")
        return response
    except Exception as e:
        print(f"Error creating user: {e}")
        return None
```

### **4. JWT Token Claims**

When users sign in, the `custom:user_id` will be included in the JWT token:

```javascript
// After successful authentication, decode the ID token
import jwt_decode from "jwt-decode";

const token = session.getIdToken().getJwtToken();
const decoded = jwt_decode(token);

console.log("User ID:", decoded["custom:user_id"]);
console.log("Email:", decoded.email);
console.log("All claims:", decoded);
```

## 🚀 **Deployment:**

1. **Deploy your infrastructure:**

   ```bash
   ./scripts/deploy.sh dev apply
   ```

2. **Get your Cognito configuration:**

   ```bash
   terraform output cognito_config
   ```

3. **Configure your application with the outputs**

## 📝 **Configuration in terraform.tfvars:**

```hcl
# Basic Cognito settings
create_cognito = true
cognito_username_attributes = ["email"]  # Login with email

# The custom:user_id attribute is configured automatically
# Additional custom attributes can be added to cognito_schemas variable
```

## 🔍 **Validation:**

Test your configuration using the demo app:

1. Open `examples/cognito-demo.html`
2. Configure with your Cognito outputs
3. Sign up a new user
4. Use browser developer tools to inspect JWT tokens and see the custom attributes

## 💡 **Best Practices:**

1. **User ID Format**: Use a consistent format like `USR001`, `USER_123`, or UUIDs
2. **Uniqueness**: Ensure custom user IDs are unique in your application logic
3. **Indexing**: Consider using the custom user ID for database lookups
4. **Validation**: Validate the format before setting the attribute

## 🎯 **Use Cases:**

- **Legacy System Integration**: Map Cognito users to existing user IDs
- **Multi-tenant Applications**: Include tenant information in user ID
- **Analytics**: Track users across different systems
- **Database Relations**: Use as foreign key in your application database

Your Cognito User Pool is now ready to use email-based authentication with custom user IDs! 🎉
