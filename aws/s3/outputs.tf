output "bucket_name" {
  description = "Name of the S3 bucket for CNPG backups"
  value       = aws_s3_bucket.cnpg_backups.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.cnpg_backups.arn
}

output "bucket_region" {
  description = "AWS region of the S3 bucket"
  value       = "ap-south-1"
}

output "iam_user_name" {
  description = "Name of the IAM user for CNPG backups"
  value       = aws_iam_user.cnpg_backup.name
}

output "access_key_id" {
  description = "Access Key ID for the CNPG backup user"
  value       = aws_iam_access_key.cnpg_backup.id
}

output "secret_access_key" {
  description = "Secret Access Key for the CNPG backup user"
  value       = aws_iam_access_key.cnpg_backup.secret
  sensitive   = true
}
