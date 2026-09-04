# =========================================================
# Sample Workload S3 Bucket
# =========================================================

resource "aws_s3_bucket" "sample" {
  bucket = var.sample_bucket_name

  tags = {
    Name    = "Terraform Security Lab Sample"
    Purpose = "Terraform backend validation"
  }
}


# =========================================================
# Object Ownership
# =========================================================

resource "aws_s3_bucket_ownership_controls" "sample" {
  bucket = aws_s3_bucket.sample.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# =========================================================
# Block Public Access
# =========================================================

resource "aws_s3_bucket_public_access_block" "sample" {
  bucket = aws_s3_bucket.sample.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# =========================================================
# Versioning
# =========================================================

resource "aws_s3_bucket_versioning" "sample" {
  bucket = aws_s3_bucket.sample.id

  versioning_configuration {
    status = "Enabled"
  }
}


# =========================================================
# Default Encryption
# =========================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "sample" {
  bucket = aws_s3_bucket.sample.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.sample.arn
    }

    bucket_key_enabled = true
  }
}

# =========================================================
# KMS Key — Sample Workload Data
# =========================================================

resource "aws_kms_key" "sample" {
  description = "Customer managed KMS key for sample workload S3 bucket"

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  enable_key_rotation = true

  deletion_window_in_days = 30

  tags = {
    Name    = "terraform-security-lab-sample"
    Purpose = "Sample workload S3 encryption"
  }
}


# =========================================================
# KMS Alias
# =========================================================

resource "aws_kms_alias" "sample" {
  name          = "alias/terraform-security-lab-sample"
  target_key_id = aws_kms_key.sample.key_id
}
