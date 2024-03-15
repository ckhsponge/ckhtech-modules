

resource "aws_s3_bucket_policy" "main" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_kms_key" "bucket" {
  count = var.encrypt_bucket ? 1 : 0
  description = "This key is used to encrypt bucket ${var.bucket_name}"
  policy = data.aws_iam_policy_document.bucket_key_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
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
