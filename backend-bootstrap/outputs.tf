output "terraform_state_bucket_name" {
  description = "Terraform state S3 bucket name"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "Terraform state S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_kms_key_arn" {
  description = "Terraform state KMS key ARN"
  value       = aws_kms_key.terraform_state.arn
}

output "terraform_state_kms_alias" {
  description = "Terraform state KMS alias"
  value       = aws_kms_alias.terraform_state.name
}