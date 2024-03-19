
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "main" {
  count = var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}





