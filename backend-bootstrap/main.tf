# =========================================================
# Terraform State S3 Bucket
# =========================================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}


# =========================================================
# S3 Object Ownership
# =========================================================

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# =========================================================
# S3 Public Access Block
# =========================================================

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# =========================================================
# S3 Versioning
# =========================================================

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}


# =========================================================
# KMS Customer Managed Key
# =========================================================

resource "aws_kms_key" "terraform_state" {
  description = "Customer managed KMS key for Terraform state encryption"

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  enable_key_rotation = true

  deletion_window_in_days = 30

  tags = {
    Name    = "terraform-prod-state"
    Purpose = "Terraform state encryption"
  }
}


# =========================================================
# KMS Alias
# =========================================================

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/terraform-prod-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}


# =========================================================
# S3 Default Encryption - SSE-KMS
# =========================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }

    bucket_key_enabled = true
  }
}


# =========================================================
# S3 Bucket Policy
# =========================================================

data "aws_iam_policy_document" "terraform_state" {

  # -------------------------------------------------------
  # Deny non-TLS requests
  # -------------------------------------------------------

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # -------------------------------------------------------
  # Require SSE-KMS for object uploads
  # -------------------------------------------------------

  statement {
    sid    = "DenyUnencryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  # -------------------------------------------------------
  # Require the specific Terraform KMS key
  # -------------------------------------------------------

  statement {
    sid    = "DenyWrongKMSKey"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [aws_kms_key.terraform_state.arn]
    }
  }
}


resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state.json
}