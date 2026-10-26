# Database Configuration - Simplified for Development
# Public access enabled for easy debugging and development

# RDS PostgreSQL Instance
resource "aws_db_instance" "badger_db" {
  identifier = "${var.project_name}-db"

  # Database configuration
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.db_instance_class

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = false  # Disabled for cost savings in dev

  # Database settings
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password  # Using variable for simplicity

  # Network configuration - public for easy access
  db_subnet_group_name   = aws_db_subnet_group.badger_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true  # Enabled for development access

  # Backup configuration - minimal for cost savings
  backup_retention_period = 1
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Monitoring - disabled for cost optimization
  monitoring_interval = 0
  enabled_cloudwatch_logs_exports = []

  # Deletion protection disabled for easy cleanup
  deletion_protection = false
  skip_final_snapshot = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-database"
  })
}

# ElastiCache Redis Cluster - Simple single-node setup
resource "aws_elasticache_replication_group" "badger_redis" {
  replication_group_id       = "${var.project_name}-redis"
  description                = "Redis cluster for Badger Delivery Service"

  # Node configuration
  node_type               = var.redis_node_type
  port                    = 6379
  parameter_group_name    = "default.redis7"

  # Simple single-node setup for development
  num_cache_clusters = 1

  # Network configuration
  subnet_group_name  = aws_elasticache_subnet_group.badger_cache_subnet_group.name
  security_group_ids = [aws_security_group.redis_sg.id]

  # Security settings - simplified for development
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false  # Disabled for simplicity
  auth_token                 = null   # No authentication for easy access

  # Backup settings - minimal
  snapshot_retention_limit = 1
  snapshot_window         = "03:00-05:00"

  # Maintenance
  maintenance_window = "sun:05:00-sun:06:00"

  # Logging disabled for cost optimization
  log_delivery_configuration {
    destination      = ""
    destination_type = ""
    log_format       = ""
    log_type         = ""
  }

  tags = var.common_tags
}
