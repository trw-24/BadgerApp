# Badger Delivery Service - AWS Infrastructure

This Terraform configuration deploys cloud infrastructure for the Badger Delivery Service to AWS using modern cloud-native architecture patterns.

**Application Repository:** The application code and container definitions are maintained in the separate `mcp_cli_test_app` repository. This infrastructure is designed to host containerized applications deployed to ECS.

## Architecture Overview

The infrastructure includes:

- **VPC & Networking** - Isolated network environment with public/private subnets
- **Application Load Balancer (ALB)** - Traffic distribution and SSL termination
- **ECS Fargate Cluster** - Serverless container orchestration platform
- **RDS PostgreSQL** - Managed relational database service
- **ElastiCache Redis** - High-performance in-memory caching layer
- **S3 Buckets** - Object storage for application files and logs
- **IAM Roles & Policies** - Service permissions and access control
- **Security Groups** - Network-level access controls

## Quick Start

1. **Prerequisites**
   ```bash
   # Install Terraform
   brew install terraform  # macOS
   # or download from https://terraform.io

   # Configure AWS CLI
   aws configure
   ```

2. **Deploy Infrastructure**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   
   terraform init
   terraform plan
   terraform apply
   ```

3. **Get Infrastructure Outputs**
   ```bash
   # Get the load balancer URL
   terraform output application_url
   
   # Get database connection details
   terraform output database_endpoint
   
   # Get all outputs
   terraform output
   ```

4. **Deploy Application**
   - Build and push application container image to ECR
   - Update ECS task definition with new image
   - See `mcp_cli_test_app` repository for application deployment procedures

## Infrastructure Configuration

### ECS Task Environment Variables

The ECS task definition is configured with environment variables for application connectivity:

- `DATABASE_URL` - RDS PostgreSQL connection string
- `REDIS_URL` - ElastiCache Redis endpoint
- `S3_BUCKET` - S3 bucket name for file storage
- Additional environment variables can be configured in `ecs.tf`

Application-specific environment variables should be added to the ECS task definition or stored in AWS Secrets Manager.

### Direct Infrastructure Access

For infrastructure debugging and administration:

```bash
# Connect to RDS PostgreSQL
psql -h $(terraform output -raw database_endpoint) -U badger_admin -d badgers

# Connect to ElastiCache Redis (requires network access)
redis-cli -h $(terraform output -raw redis_endpoint)

# Access S3 bucket
aws s3 ls s3://$(terraform output -raw s3_bucket_name)
```

**Note:** Direct access may require VPN or bastion host depending on security group configuration.

## Infrastructure Features

### Development/Testing Configuration

This configuration includes development-friendly features:

- **Simplified Networking** - Public subnets for easier access during development
- **Direct Access** - Database and cache endpoints accessible for debugging
- **Cost Optimization** - Right-sized instances for development workloads
- **Minimal Redundancy** - Single AZ deployment to reduce costs

### Production Hardening Recommendations

Before production deployment, consider:

- **Multi-AZ Deployment** - Enable for high availability
- **Private Subnets** - Move database and cache to private subnets
- **Bastion Hosts** - Add jump boxes for secure access
- **WAF** - Enable AWS WAF on the ALB
- **Enhanced Monitoring** - Enable detailed CloudWatch metrics
- **Backup Strategy** - Configure automated backups and snapshots
- **Secrets Management** - Move credentials to AWS Secrets Manager

## File Structure

```
terraform/
├── main.tf              # Core infrastructure (ALB, ECS cluster)
├── networking.tf        # VPC, subnets, routing
├── security.tf          # Security groups and IAM roles
├── database.tf          # RDS and ElastiCache
├── storage.tf           # S3 bucket configuration
├── ecs.tf              # ECS task and service definitions
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars.example  # Example configuration
└── README.md           # This file
```

## Infrastructure Outputs

After deployment, the following infrastructure details are available:

```bash
terraform output application_url           # ALB DNS name
terraform output database_endpoint         # RDS endpoint
terraform output database_connection_string # Full PostgreSQL connection string
terraform output redis_endpoint            # ElastiCache endpoint
terraform output s3_bucket_name           # S3 bucket for application storage
terraform output vpc_id                    # VPC ID
terraform output ecs_cluster_name          # ECS cluster name
terraform output ecs_service_name          # ECS service name
```

These outputs are used for:
- Configuring application deployment in `mcp_cli_test_app`
- Infrastructure monitoring and troubleshooting
- Integration with other AWS services

## Cost Optimization

This configuration uses the following cost optimization strategies:

- **t3.micro instances** for RDS and ElastiCache
- **Minimal ECS resources** (256 CPU, 512 MB memory)
- **Single AZ deployment** to avoid cross-AZ charges
- **Disabled monitoring** and logging features
- **Short backup retention** (1 day)
- **No auto-scaling** to prevent unexpected costs

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## Security Considerations

⚠️ **Development-Optimized Configuration** ⚠️

This infrastructure configuration prioritizes development convenience and includes security trade-offs:

**Network Security:**
- Public database access for development tools
- Permissive security groups for easier testing
- Public ALB for direct access

**Credentials & Access:**
- Database credentials in Terraform state
- IAM roles with broad permissions
- No MFA requirements

**Monitoring & Logging:**
- Minimal CloudWatch logging to reduce costs
- Basic VPC Flow Logs
- No GuardDuty or Security Hub

**Production Security Hardening:**

Before deploying to production:
1. Move database to private subnets
2. Implement AWS Secrets Manager for credentials
3. Enable AWS GuardDuty and Security Hub
4. Configure VPC endpoints for AWS services
5. Enable MFA for IAM users
6. Implement least-privilege IAM policies
7. Enable AWS WAF on ALB
8. Configure backup encryption and retention
9. Review security group rules for least privilege
10. Enable CloudTrail for audit logging

See `docs/cloud-controls-framework.md` for comprehensive security requirements.

## Troubleshooting

### Common Infrastructure Issues

1. **ECS Task Fails to Start**
   - Check CloudWatch logs: `/ecs/badger-delivery`
   - Verify container image exists in ECR
   - Check ECS task IAM role permissions
   - Verify network connectivity to RDS/ElastiCache

2. **Database Connection Issues**
   - Verify security group rules allow traffic from ECS tasks
   - Check database endpoint DNS resolution
   - Test credentials from bastion host
   - Review RDS instance status

3. **Load Balancer Health Checks Failing**
   - Verify target group configuration
   - Check security group allows ALB → ECS traffic
   - Review application health check endpoint
   - Inspect ECS task network mode

4. **Terraform Apply Failures**
   - Check AWS service quotas
   - Verify IAM permissions for Terraform
   - Review resource naming conflicts
   - Check AWS region availability

### Infrastructure Management Commands

```bash
# ECS cluster status
aws ecs describe-clusters --clusters badger-delivery-cluster

# ECS service status
aws ecs describe-services --cluster badger-delivery-cluster --services badger-delivery-service

# RDS instance status
aws rds describe-db-instances --db-instance-identifier badger-delivery-db

# ElastiCache cluster status
aws elasticache describe-cache-clusters --cache-cluster-id badger-delivery-redis

# ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# View infrastructure logs
aws logs tail /ecs/badger-delivery --follow
```

## Related Documentation

- **Application Deployment:** See `mcp_cli_test_app` repository
- **Local Testing:** See `../docker/README.md`
- **Security Controls:** See `../docs/cloud-controls-framework.md`
- **Infrastructure Operations:** See `../docs/README.md`

## Support

For infrastructure issues:
1. Check AWS resource status in console
2. Review CloudWatch logs for service errors
3. Verify Terraform state matches deployed resources
4. Consult cloud-controls-framework.md for operational procedures
