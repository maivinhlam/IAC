#!/bin/bash

# Setup script for Terraform project
# This script helps set up the initial configuration

set -e

echo "=== Terraform Project Setup ==="

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed. Please install Terraform first."
    echo "Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

echo "✓ Terraform is installed: $(terraform version | head -n 1)"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Warning: AWS CLI is not installed. You may need it for authentication."
    echo "Visit: https://aws.amazon.com/cli/"
else
    echo "✓ AWS CLI is installed: $(aws --version)"
fi

# Make scripts executable
chmod +x scripts/*.sh
echo "✓ Made scripts executable"

# Create terraform.tfvars files from examples
for env in dev staging prod; do
    if [[ ! -f "environments/$env/terraform.tfvars" ]]; then
        if [[ -f "environments/$env/terraform.tfvars.example" ]]; then
            cp "environments/$env/terraform.tfvars.example" "environments/$env/terraform.tfvars"
            echo "✓ Created terraform.tfvars for $env environment"
        fi
    else
        echo "✓ terraform.tfvars already exists for $env environment"
    fi
done

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Configure AWS credentials:"
echo "   aws configure"
echo "   # OR set environment variables:"
echo "   export AWS_ACCESS_KEY_ID=your_access_key"
echo "   export AWS_SECRET_ACCESS_KEY=your_secret_key"
echo ""
echo "2. Customize terraform.tfvars files for each environment:"
echo "   - environments/dev/terraform.tfvars"
echo "   - environments/staging/terraform.tfvars"
echo "   - environments/prod/terraform.tfvars"
echo ""
echo "3. Initialize and deploy your first environment:"
echo "   ./scripts/deploy.sh dev init"
echo "   ./scripts/deploy.sh dev plan"
echo "   ./scripts/deploy.sh dev apply"
echo ""
echo "4. (Optional) Set up remote state storage:"
echo "   - Create an S3 bucket for state storage"
echo "   - Create a DynamoDB table for state locking"
echo "   - Uncomment and configure backend blocks in main.tf files"
echo ""
echo "Happy Terraforming! 🚀"
