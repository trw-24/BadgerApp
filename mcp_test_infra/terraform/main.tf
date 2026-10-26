# Badger Delivery Service - AWS Infrastructure
# Optimized for cost and simplicity in development environment

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Application Load Balancer
resource "aws_lb" "badger_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]

  # Simple access logging to public bucket for easy debugging
  access_logs {
    bucket  = aws_s3_bucket.app_storage.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  tags = var.common_tags
}

resource "aws_lb_target_group" "badger_tg" {
  name     = "${var.project_name}-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "badger_listener" {
  load_balancer_arn = aws_lb.badger_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.badger_tg.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "badger_cluster" {
  name = "${var.project_name}-cluster"

  # Simplified configuration for development
  setting {
    name  = "containerInsights"
    value = "disabled"  # Disabled to reduce costs
  }

  tags = var.common_tags
}

# CloudWatch Log Group (minimal logging for cost savings)
resource "aws_cloudwatch_log_group" "badger_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 3  # Short retention for cost optimization

  tags = var.common_tags
}
