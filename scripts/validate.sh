#!/bin/bash

# Terraform validation script
# Validates all environments and modules

set -e

echo "=== Terraform Configuration Validation ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to validate a directory
validate_directory() {
    local dir=$1
    local name=$2
    
    if [[ ! -d "$dir" ]]; then
        echo -e "${RED}✗ Directory $dir does not exist${NC}"
        return 1
    fi
    
    cd "$dir"
    echo -e "${YELLOW}Validating $name...${NC}"
    
    # Check if terraform files exist
    if ! ls *.tf >/dev/null 2>&1; then
        echo -e "${RED}✗ No Terraform files found in $dir${NC}"
        cd - >/dev/null
        return 1
    fi
    
    # Initialize if needed (quietly)
    if [[ ! -d ".terraform" ]]; then
        echo "  Initializing Terraform..."
        terraform init -backend=false >/dev/null 2>&1
    fi
    
    # Validate
    if terraform validate >/dev/null 2>&1; then
        echo -e "${GREEN}✓ $name is valid${NC}"
        cd - >/dev/null
        return 0
    else
        echo -e "${RED}✗ $name validation failed${NC}"
        terraform validate
        cd - >/dev/null
        return 1
    fi
}

# Function to format terraform files
format_files() {
    echo -e "${YELLOW}Formatting Terraform files...${NC}"
    if terraform fmt -recursive -check >/dev/null 2>&1; then
        echo -e "${GREEN}✓ All files are properly formatted${NC}"
    else
        echo -e "${YELLOW}! Some files need formatting. Running terraform fmt...${NC}"
        terraform fmt -recursive
        echo -e "${GREEN}✓ Files formatted${NC}"
    fi
}

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}✗ Terraform is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Terraform is installed: $(terraform version | head -n 1)${NC}"

# Format all files
format_files

# Validate global configuration
if ! validate_directory "global" "Global Configuration"; then
    exit 1
fi

# Validate modules
echo ""
echo "=== Validating Modules ==="
modules=("vpc" "compute" "database")
for module in "${modules[@]}"; do
    if ! validate_directory "modules/$module" "Module: $module"; then
        exit 1
    fi
done

# Validate environments
echo ""
echo "=== Validating Environments ==="
environments=("dev" "staging" "prod")
for env in "${environments[@]}"; do
    if ! validate_directory "environments/$env" "Environment: $env"; then
        exit 1
    fi
done

echo ""
echo -e "${GREEN}=== All validations passed! ✓ ===${NC}"
echo ""
echo "Next steps:"
echo "1. Configure your terraform.tfvars files"
echo "2. Set up AWS credentials"
echo "3. Run: ./scripts/deploy.sh dev init"
echo "4. Run: ./scripts/deploy.sh dev plan"
