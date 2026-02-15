terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# S3 Bucket for CNPG backups
resource "aws_s3_bucket" "cnpg_backups" {
  bucket = "maskudo-homelab-backups"

  tags = {
    Name        = "CNPG Backups"
    Description = "S3 bucket for CloudNativePG WAL archiving and base backups"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "cnpg_backups" {
  bucket = aws_s3_bucket.cnpg_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cnpg_backups" {
  bucket = aws_s3_bucket.cnpg_backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "cnpg_backups" {
  bucket = aws_s3_bucket.cnpg_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rule: delete old versions after 15 days, keep latest forever
resource "aws_s3_bucket_lifecycle_configuration" "cnpg_backups" {
  bucket = aws_s3_bucket.cnpg_backups.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    # Only delete non-current (old) versions after 15 days
    # Current (latest) versions are kept indefinitely
    noncurrent_version_expiration {
      noncurrent_days = 15
    }
  }
}

# IAM User for CNPG backups
resource "aws_iam_user" "cnpg_backup" {
  name = "cnpg-backup-user"

  tags = {
    Name        = "CNPG Backup User"
    Description = "IAM user for CloudNativePG S3 backup operations"
  }
}

# IAM Policy for CNPG backups (CRUD only on this specific bucket)
resource "aws_iam_policy" "cnpg_backup" {
  name        = "cnpg-backup-policy"
  description = "Policy allowing CRUD operations on the CNPG backup S3 bucket only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.cnpg_backups.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.cnpg_backups.arn}/*"
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "cnpg_backup" {
  user       = aws_iam_user.cnpg_backup.name
  policy_arn = aws_iam_policy.cnpg_backup.arn
}

# Create access key for the user
resource "aws_iam_access_key" "cnpg_backup" {
  user = aws_iam_user.cnpg_backup.name
}
