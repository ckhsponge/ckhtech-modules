

resource "aws_s3_bucket" "main" {
  // appending --bucket prevents direct domain mapping
  bucket = var.bucket_name //"${var.bucket_name}--bucket"
#  provider = aws.main
}

resource "aws_s3_bucket_versioning" "main" {
  count = var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id
#  provider = aws.main

  versioning_configuration {
    status = "Enabled"
  }
}
