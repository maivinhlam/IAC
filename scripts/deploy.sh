#!/bin/bash

# Terraform deployment script
# Usage: ./deploy.sh <environment> <action>
# Example: ./deploy.sh dev plan
# Example: ./deploy.sh prod apply

set -e

ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "Error: Environment must be one of: dev, staging, prod"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy|init|validate|fmt)$ ]]; then
    echo "Error: Action must be one of: plan, apply, destroy, init, validate, fmt"
    exit 1
fi

ENVIRONMENT_DIR="environments/$ENVIRONMENT"

# Check if environment directory exists
if [[ ! -d "$ENVIRONMENT_DIR" ]]; then
    echo "Error: Environment directory $ENVIRONMENT_DIR does not exist"
    exit 1
fi

echo "=== Terraform $ACTION for $ENVIRONMENT environment ==="
echo "Working directory: $ENVIRONMENT_DIR"

cd "$ENVIRONMENT_DIR"

case $ACTION in
    init)
        echo "Initializing Terraform..."
        terraform init
        ;;
    validate)
        echo "Validating Terraform configuration..."
        terraform validate
        ;;
    fmt)
        echo "Formatting Terraform files..."
        terraform fmt -recursive
        ;;
    plan)
        echo "Planning Terraform changes..."
        terraform plan -out=tfplan
        ;;
    apply)
        echo "Applying Terraform changes..."
        if [[ -f "tfplan" ]]; then
            terraform apply tfplan
            rm tfplan
        else
            echo "Warning: No plan file found. Running apply without plan..."
            read -p "Do you want to continue? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                terraform apply
            else
                echo "Cancelled."
                exit 1
            fi
        fi
        ;;
    destroy)
        echo "Destroying Terraform resources..."
        echo "WARNING: This will destroy all resources in the $ENVIRONMENT environment!"
        read -p "Are you sure? Type 'yes' to confirm: " confirm
        if [[ "$confirm" == "yes" ]]; then
            terraform destroy
        else
            echo "Cancelled."
            exit 1
        fi
        ;;
esac

echo "=== Terraform $ACTION completed for $ENVIRONMENT ==="
