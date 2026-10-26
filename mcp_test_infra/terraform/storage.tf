# Storage Configuration - S3 Bucket for Application Files
# Public access enabled for easy file sharing and debugging

# S3 Bucket for application storage
resource "aws_s3_bucket" "app_storage" {
  bucket = "${var.project_name}-storage-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-storage"
  })
}

# Random suffix for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Public access configuration for easy file sharing
resource "aws_s3_bucket_public_access_block" "app_storage_pab" {
  bucket = aws_s3_bucket.app_storage.id

  # Allow public access for development convenience
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for public read access
resource "aws_s3_bucket_policy" "app_storage_policy" {
  bucket = aws_s3_bucket.app_storage.id
  depends_on = [aws_s3_bucket_public_access_block.app_storage_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.app_storage.arn}/*"
      },
      {
        Sid       = "PublicListBucket"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = aws_s3_bucket.app_storage.arn
      }
    ]
  })
}

# Bucket versioning - disabled for cost savings
resource "aws_s3_bucket_versioning" "app_storage_versioning" {
  bucket = aws_s3_bucket.app_storage.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Server-side encryption - disabled for simplicity
resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage_encryption" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Basic encryption, no KMS for cost savings
    }
  }
}

# Lifecycle configuration - short retention for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "app_storage_lifecycle" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    id     = "delete_old_files"
    status = "Enabled"

    expiration {
      days = 30  # Delete files after 30 days
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

# CORS configuration for web access
resource "aws_s3_bucket_cors_configuration" "app_storage_cors" {
  bucket = aws_s3_bucket.app_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]  # Allow from any origin for development
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Bucket notification for webhook integration (optional)
resource "aws_s3_bucket_notification" "app_storage_notification" {
  bucket = aws_s3_bucket.app_storage.id

  # Could add Lambda or SQS notifications here for file processing
}
