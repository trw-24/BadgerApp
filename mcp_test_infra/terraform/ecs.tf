# ECS Configuration - Container Orchestration
# Simplified setup with broad permissions for development flexibility

# ECS Task Definition
resource "aws_ecs_task_definition" "badger_app" {
  family                   = "${var.project_name}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = var.ecs_cpu
  memory                  = var.ecs_memory

  # IAM roles
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "badger-app"
      image = var.app_image
      
      # Port configuration
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      # Environment variables - hardcoded for simplicity
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.badger_db.endpoint}/${var.db_name}"
        },
        {
          name  = "REDIS_URL"
          value = "redis://${aws_elasticache_replication_group.badger_redis.primary_endpoint_address}:6379"
        },
        {
          name  = "SECRET_KEY"
          value = "badger-secret-key-2023-production"  # Hardcoded for convenience
        },
        {
          name  = "BADGER_API"
          value = "https://api.wildlifetrackers.com/badgers"
        },
        {
          name  = "S3_BUCKET"
          value = aws_s3_bucket.app_storage.bucket
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        },
        {
          name  = "FLASK_ENV"
          value = "production"
        },
        {
          name  = "DEBUG"
          value = "true"  # Debug enabled in production for troubleshooting
        }
      ]

      # Logging configuration - minimal for cost savings
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.badger_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      # Resource limits - generous for development
      memory = var.ecs_memory
      cpu    = var.ecs_cpu

      # Security - running as root for simplicity
      user = "0"

      # Health check - basic
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:5000/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      # Essential container
      essential = true
    }
  ])

  tags = var.common_tags
}

# ECS Service
resource "aws_ecs_service" "badger_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.badger_cluster.id
  task_definition = aws_ecs_task_definition.badger_app.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  # Network configuration - public subnets for simplicity
  network_configuration {
    subnets          = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true  # Public IP for easy access and debugging
  }

  # Load balancer configuration
  load_balancer {
    target_group_arn = aws_lb_target_group.badger_tg.arn
    container_name   = "badger-app"
    container_port   = 5000
  }

  # Service discovery disabled for simplicity
  # service_registries = []

  # Deployment configuration - fast rollouts
  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
  }

  # Auto-scaling disabled for cost optimization
  # enable_execute_command = true  # For debugging access

  depends_on = [
    aws_lb_listener.badger_listener,
    aws_iam_role_policy.ecs_task_policy
  ]

  tags = var.common_tags
}

# Application Auto Scaling Target (optional - commented out for cost savings)
# resource "aws_appautoscaling_target" "ecs_target" {
#   max_capacity       = 10
#   min_capacity       = 1
#   resource_id        = "service/${aws_ecs_cluster.badger_cluster.name}/${aws_ecs_service.badger_service.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# Auto Scaling Policy (optional - commented out for cost savings)
# resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
#   name               = "${var.project_name}-cpu-scaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     target_value = 70.0
#   }
# }
