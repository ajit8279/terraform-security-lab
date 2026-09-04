output "sample_bucket_name" {
  description = "Name of the sample workload S3 bucket"
  value       = aws_s3_bucket.sample.bucket
}

output "sample_bucket_arn" {
  description = "ARN of the sample workload S3 bucket"
  value       = aws_s3_bucket.sample.arn
}

output "sample_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt the sample S3 bucket"
  value       = aws_kms_key.sample.arn
}

output "sample_kms_alias" {
  description = "Alias of the KMS key used to encrypt the sample S3 bucket"
  value       = aws_kms_alias.sample.name
}