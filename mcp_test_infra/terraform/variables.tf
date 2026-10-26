# Variables for Badger Delivery Service Infrastructure
# Configured for development environment with cost optimization

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "badger-delivery"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

# Database Configuration
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"  # Small instance for cost savings
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "badgers"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "badger_admin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  default     = "BadgerPass123!"  # Hardcoded for simplicity
  sensitive   = false  # Not marked sensitive for easy debugging
}

# Redis Configuration
variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"  # Small instance for cost savings
}

# ECS Configuration
variable "ecs_cpu" {
  description = "CPU units for ECS task (1024 = 1 vCPU)"
  type        = number
  default     = 256  # Small for cost optimization
}

variable "ecs_memory" {
  description = "Memory (MB) for ECS task"
  type        = number
  default     = 512  # Small for cost optimization
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1  # Single instance for cost savings
}

variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "nginx:latest"  # Placeholder - would be replaced with actual app image
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "BadgerDelivery"
    Environment = "Development"
    Owner       = "DevTeam"
    CostCenter  = "Engineering"
    Backup      = "false"
    Monitoring  = "basic"
  }
}
