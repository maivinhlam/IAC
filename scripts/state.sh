#!/bin/bash

# Terraform state management script
# Usage: ./state.sh <environment> <action>

set -e

ENVIRONMENT=${1:-dev}
ACTION=${2:-list}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "Error: Environment must be one of: dev, staging, prod"
    exit 1
fi

ENVIRONMENT_DIR="environments/$ENVIRONMENT"

# Check if environment directory exists
if [[ ! -d "$ENVIRONMENT_DIR" ]]; then
    echo "Error: Environment directory $ENVIRONMENT_DIR does not exist"
    exit 1
fi

echo "=== Terraform state $ACTION for $ENVIRONMENT environment ==="

cd "$ENVIRONMENT_DIR"

case $ACTION in
    list)
        echo "Listing Terraform state resources..."
        terraform state list
        ;;
    show)
        if [[ -z "$3" ]]; then
            echo "Error: Resource name required for show action"
            echo "Usage: ./state.sh $ENVIRONMENT show <resource_name>"
            echo "Example: ./state.sh $ENVIRONMENT show module.vpc.aws_vpc.main"
            exit 1
        fi
        echo "Showing state for resource: $3"
        terraform state show "$3"
        ;;
    refresh)
        echo "Refreshing Terraform state..."
        terraform refresh
        ;;
    pull)
        echo "Pulling remote state..."
        terraform state pull
        ;;
    backup)
        echo "Creating state backup..."
        BACKUP_FILE="terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)"
        terraform state pull > "$BACKUP_FILE"
        echo "State backed up to: $BACKUP_FILE"
        ;;
    *)
        echo "Error: Unknown action '$ACTION'"
        echo "Available actions: list, show, refresh, pull, backup"
        exit 1
        ;;
esac

echo "=== State $ACTION completed ==="
