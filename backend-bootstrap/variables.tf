variable "aws_region" {
  description = "AWS region where the Terraform backend will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region must be a valid AWS region format."
  }
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name used for Terraform state"
  type        = string

  validation {
    condition     = length(var.state_bucket_name) >= 3 && length(var.state_bucket_name) <= 63
    error_message = "state_bucket_name must be between 3 and 63 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must contain only lowercase letters, numbers, dots, and hyphens."
  }
}

variable "environment" {
  description = "Environment associated with the backend"
  type        = string
  default     = "production"

  validation {
    condition     = var.environment == "production"
    error_message = "This bootstrap is intentionally restricted to the production backend."
  }
}