

resource "aws_s3_bucket_policy" "main" {
  count = length(var.cloudfront_distribution_arns) > 0 ? 1 : 0
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_kms_key" "bucket" {
  count = var.encrypt_with_custom_kms ? 1 : 0
  description = "This key is used to encrypt bucket ${var.bucket_name}"
  policy = data.aws_iam_policy_document.bucket_key_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "custom" {
  count = length(aws_kms_key.bucket)
  bucket = var.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket[count.index].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "standard" {
  count = length(aws_kms_key.bucket) < 1 && var.encrypt_bucket ? 1 : 0
  bucket = var.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
    bucket_key_enabled = true
  }
}
