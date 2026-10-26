# Outputs for Badger Delivery Service Infrastructure
# Provides connection information for the deployed resources

output "application_url" {
  description = "URL of the application load balancer"
  value       = "http://${aws_lb.badger_alb.dns_name}"
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.badger_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the application load balancer"
  value       = aws_lb.badger_alb.zone_id
}

# Database connection information
output "database_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.badger_db.endpoint
}

output "database_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.badger_db.port
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.badger_db.db_name
}

output "database_username" {
  description = "Database username"
  value       = aws_db_instance.badger_db.username
  sensitive   = false  # Not marked sensitive for easy access
}

# Redis connection information
output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = aws_elasticache_replication_group.badger_redis.primary_endpoint_address
}

output "redis_port" {
  description = "ElastiCache Redis port"
  value       = aws_elasticache_replication_group.badger_redis.port
}

# S3 bucket information
output "s3_bucket_name" {
  description = "S3 bucket name for application storage"
  value       = aws_s3_bucket.app_storage.bucket
}

output "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.app_storage.bucket_domain_name
}

output "s3_bucket_website_endpoint" {
  description = "S3 bucket website endpoint"
  value       = aws_s3_bucket.app_storage.website_endpoint
}

# Network information
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
}

# ECS information
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.badger_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.badger_service.name
}

# Security group IDs for reference
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb_sg.id
}

output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = aws_security_group.ecs_sg.id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = aws_security_group.redis_sg.id
}

# Connection strings for easy application configuration
output "database_connection_string" {
  description = "Full database connection string"
  value       = "postgresql://${aws_db_instance.badger_db.username}:${var.db_password}@${aws_db_instance.badger_db.endpoint}/${aws_db_instance.badger_db.db_name}"
  sensitive   = false  # Not marked sensitive for easy debugging
}

output "redis_connection_string" {
  description = "Redis connection string"
  value       = "redis://${aws_elasticache_replication_group.badger_redis.primary_endpoint_address}:${aws_elasticache_replication_group.badger_redis.port}"
}
