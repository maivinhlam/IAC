# Infrastructure as Code (IAC) with Terraform

This is a comprehensive Terraform Infrastructure as Code project that implements AWS infrastructure with best practices including:

- **Modular Design**: Reusable modules for VPC, Compute, and Database components
- **Multi-Environment Support**: Separate configurations for dev, staging, and production
- **Security Best Practices**: Private subnets, security groups, encryption
- **Scalability**: Auto Scaling Groups, Load Balancers (configurable)
- **High Availability**: Multi-AZ deployments, read replicas

## Quick Start

1. **Setup the project:**

   ```bash
   ./scripts/setup.sh
   ```

2. **Configure AWS credentials:**

   ```bash
   aws configure
   # OR
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key
   ```

3. **Deploy to development environment:**

   ```bash
   # Initialize Terraform
   ./scripts/deploy.sh dev init

   # Plan the deployment
   ./scripts/deploy.sh dev plan

   # Apply the changes
   ./scripts/deploy.sh dev apply
   ```

## Project Structure

```
IAC/
├── README.md                     # This file
├── .gitignore                   # Git ignore rules
├── global/                      # Global Terraform configuration
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── modules/                     # Reusable Terraform modules
│   ├── vpc/                     # VPC module (networks, subnets, gateways)
│   ├── compute/                 # Compute module (EC2, ASG, security groups)
│   └── database/                # Database module (RDS, parameter groups)
├── environments/                # Environment-specific configurations
│   ├── dev/                     # Development environment
│   ├── staging/                 # Staging environment
│   └── prod/                    # Production environment
└── scripts/                     # Utility scripts
    ├── setup.sh                 # Initial project setup
    ├── deploy.sh                # Deployment script
    └── state.sh                 # State management
```

## Modules Overview

### VPC Module (`modules/vpc/`)

- Creates VPC with public and private subnets
- Internet Gateway for public access
- NAT Gateways for private subnet internet access
- Route tables and security groups
- Multi-AZ support

### Compute Module (`modules/compute/`)

- EC2 instances with Auto Scaling Groups
- Security groups with web and SSH access
- Launch templates with user data
- Key pair management
- Load balancer integration support

### Database Module (`modules/database/`)

- RDS instances with MySQL/PostgreSQL support
- Multi-AZ deployments for high availability
- Read replicas for performance
- Automated backups and maintenance
- Performance Insights and enhanced monitoring
- Encryption at rest

## Environment Configurations

### Development (`environments/dev/`)

- **Purpose**: Development and testing
- **Network**: Single AZ, public subnets allowed
- **Compute**: t3.micro instances, minimal scaling
- **Database**: Single AZ, minimal backups, deletion allowed
- **Cost**: Optimized for low cost

### Staging (`environments/staging/`)

- **Purpose**: Pre-production testing
- **Network**: Multi-AZ, private subnets preferred
- **Compute**: t3.small instances, moderate scaling
- **Database**: Single AZ, weekly backups, snapshots enabled
- **Security**: Production-like security

### Production (`environments/prod/`)

- **Purpose**: Live production workloads
- **Network**: Multi-AZ, private subnets only
- **Compute**: t3.medium+ instances, full scaling
- **Database**: Multi-AZ, daily backups, read replicas, enhanced monitoring
- **Security**: Maximum security, deletion protection

## Usage Examples

### Deploy to Different Environments

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

### State Management

```bash
# List all resources
./scripts/state.sh dev list

# Show specific resource
./scripts/state.sh dev show module.vpc.aws_vpc.main

# Backup state
./scripts/state.sh dev backup
```

### Cleanup

```bash
# Destroy development environment
./scripts/deploy.sh dev destroy

# Destroy all environments (be careful!)
for env in dev staging prod; do
  ./scripts/deploy.sh $env destroy
done
```

## Customization

### Variables

Each environment has its own `variables.tf` file with default values. Override them by:

1. **terraform.tfvars file** (recommended):

   ```hcl
   project_name = "my-app"
   aws_region   = "us-east-1"
   instance_type = "t3.small"
   ```

2. **Environment variables**:

   ```bash
   export TF_VAR_project_name="my-app"
   export TF_VAR_aws_region="us-east-1"
   ```

3. **Command line**:
   ```bash
   terraform apply -var="project_name=my-app" -var="aws_region=us-east-1"
   ```

### Remote State (Recommended for Teams)

1. Create S3 bucket and DynamoDB table:

   ```bash
   # Create S3 bucket for state
   aws s3 mb s3://your-terraform-state-bucket

   # Create DynamoDB table for locking
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
   ```

2. Uncomment and configure backend blocks in each `main.tf` file:
   ```hcl
   backend "s3" {
     bucket         = "your-terraform-state-bucket"
     key            = "environments/dev/terraform.tfstate"
     region         = "us-west-2"
     dynamodb_table = "terraform-state-lock"
     encrypt        = true
   }
   ```

## Security Considerations

- **Secrets Management**: Never commit passwords or keys. Use AWS Secrets Manager or environment variables
- **Network Security**: Production uses private subnets only
- **Encryption**: All storage and databases are encrypted
- **Access Control**: Use IAM roles and security groups for access control
- **Monitoring**: Enable CloudTrail and CloudWatch for audit trails

## Cost Optimization

- **Development**: Uses t3.micro instances (free tier eligible)
- **Auto Scaling**: Scales down during low usage
- **Resource Tagging**: All resources are tagged for cost allocation
- **Storage**: Uses gp3 volumes for better cost/performance

## Troubleshooting

### Common Issues

1. **AWS Credentials**:

   ```bash
   aws sts get-caller-identity
   ```

2. **Terraform State Lock**:

   ```bash
   terraform force-unlock <lock-id>
   ```

3. **Resource Conflicts**:
   ```bash
   terraform import <resource> <id>
   ```

### Getting Help

- Check Terraform documentation: https://terraform.io/docs
- AWS Provider documentation: https://registry.terraform.io/providers/hashicorp/aws
- Terraform community: https://discuss.hashicorp.com/

## Contributing

1. Follow Terraform best practices
2. Test changes in development environment first
3. Update documentation for new features
4. Use consistent naming conventions

## License

This project is provided as-is for educational and demonstration purposes.
