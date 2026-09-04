variable "aws_region" {
  description = "AWS region for the workload"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"

  validation {
    condition     = var.environment == "production"
    error_message = "This lab workload is restricted to the production environment."
  }
}

variable "sample_bucket_name" {
  description = "Globally unique name for the sample workload bucket"
  type        = string

  validation {
    condition     = length(var.sample_bucket_name) >= 3 && length(var.sample_bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters."
  }
}