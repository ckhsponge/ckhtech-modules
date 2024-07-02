
resource "aws_s3_bucket" "files" {
  count = var.create_files_bucket ? 1 : 0
  bucket = var.files_bucket
  force_destroy = true // allows Terraform to delete bucket and its contents
}

data aws_s3_bucket files {
  depends_on = [aws_s3_bucket.files]
  bucket = var.files_bucket
}

resource "aws_s3_bucket_policy" "main" {
  depends_on = [aws_s3_bucket.files]
  # bucket policy isn't needed if there is no cloudfront
  count = var.create_bucket_policy && var.create_cloudfront ? 1 : 0
  bucket = var.files_bucket
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_kms_key" "bucket" {
  count = var.encrypt_bucket ? 1 : 0
  description = "This key is used to encrypt bucket ${var.files_bucket}"
  policy = data.aws_iam_policy_document.bucket_key_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  depends_on = [aws_s3_bucket.files]
  count = length(aws_kms_key.bucket)
  bucket = var.files_bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket[count.index].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
