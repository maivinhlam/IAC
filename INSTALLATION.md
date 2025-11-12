# Terraform Installation Guide

This guide will help you install Terraform on your system.

## macOS Installation

### Option 1: Using Homebrew (Recommended)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Terraform
brew install terraform

# Verify installation
terraform --version
```

### Option 2: Manual Installation

```bash
# Download the latest version
curl -O https://releases.hashicorp.com/terraform/1.6.4/terraform_1.6.4_darwin_amd64.zip

# Unzip and move to PATH
unzip terraform_1.6.4_darwin_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform --version
```

## Linux Installation

### Ubuntu/Debian

```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update and install
sudo apt update && sudo apt install terraform

# Verify installation
terraform --version
```

### CentOS/RHEL

```bash
# Add HashiCorp repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Install Terraform
sudo yum -y install terraform

# Verify installation
terraform --version
```

## Windows Installation

### Option 1: Using Chocolatey

```powershell
# Install Chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Terraform
choco install terraform

# Verify installation
terraform --version
```

### Option 2: Manual Installation

1. Download the latest version from: https://www.terraform.io/downloads
2. Extract the ZIP file
3. Add the terraform.exe to your PATH
4. Verify installation: `terraform --version`

## AWS CLI Installation

You'll also need AWS CLI for authentication:

### macOS

```bash
# Using Homebrew
brew install awscli

# Or using pip
pip3 install awscli
```

### Linux

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install awscli

# CentOS/RHEL
sudo yum install awscli
```

### Windows

```powershell
# Using Chocolatey
choco install awscli

# Or download from: https://aws.amazon.com/cli/
```

## Post-Installation Setup

### 1. Configure AWS Credentials

```bash
# Interactive configuration
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"
```

### 2. Verify AWS Access

```bash
# Check your identity
aws sts get-caller-identity

# List S3 buckets (if you have any)
aws s3 ls
```

### 3. Test Terraform

```bash
# Navigate to your project
cd /path/to/your/IAC/project

# Run validation
./scripts/validate.sh

# Initialize development environment
./scripts/deploy.sh dev init
```

## Quick Start After Installation

1. **Clone or navigate to your IAC project**
2. **Run the setup script:**
   ```bash
   ./scripts/setup.sh
   ```
3. **Configure your variables:**
   ```bash
   cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
   # Edit the file with your values
   ```
4. **Deploy:**
   ```bash
   ./scripts/deploy.sh dev init
   ./scripts/deploy.sh dev plan
   ./scripts/deploy.sh dev apply
   ```

## Troubleshooting

### Common Issues

1. **Permission denied**:

   ```bash
   sudo chmod +x /usr/local/bin/terraform
   ```

2. **Command not found**:

   ```bash
   # Add to your shell profile (.bashrc, .zshrc, etc.)
   export PATH=$PATH:/usr/local/bin
   ```

3. **AWS credentials not found**:
   ```bash
   aws configure list
   # If empty, run: aws configure
   ```

### Getting Help

- Terraform documentation: https://terraform.io/docs
- AWS CLI documentation: https://docs.aws.amazon.com/cli/
- HashiCorp Learn: https://learn.hashicorp.com/terraform
