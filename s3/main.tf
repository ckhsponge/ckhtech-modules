locals {
  bucket_name = join("-",
    var.namespace_first ? compact([var.namespace, var.environment, var.identifier]) :
    compact([var.identifier, var.namespace, var.environment])
  )
}

resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "main" {
  count  = var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "main" {
  count  = var.cors_enabled ? 1 : 0
  bucket = aws_s3_bucket.main.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = var.cors_domains
    max_age_seconds = 3000
  }
}




