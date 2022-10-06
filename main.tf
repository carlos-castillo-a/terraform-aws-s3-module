# Create bucket(s)
resource "aws_s3_bucket" "this" {
  bucket = var.name_override != "" ? var.name_override : format("%s-%03d%s", local.name, count.index + 1, local.name_suffix)
  count  = var.num

  tags = merge({
    module = "s3-module"
  }, var.tags)
}

# Public Access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this[count.index].id
  count  = var.num

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this[count.index].id
  count  = var.num

  versioning_configuration {
    status = var.versioning_status
  }
}

# Server Side Encryption (Always enabled)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this[count.index].id
  count  = var.num

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      # Default Master key is AWS/s3
    }
  }
}

# ACL (always private)
resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this[count.index].id
  count  = var.num

  acl    = "private"
}