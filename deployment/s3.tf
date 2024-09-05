module input_bucket {
  count = 1
  source      = "../s3"
  aws_region  = var.aws_region
  identifier  = "deployment-input"
  namespace   = var.namespace
  environment = var.environment
}

module codepipline_bucket {
  source      = "../s3"
  aws_region  = var.aws_region
  identifier  = "deployment-codepipeline"
  namespace   = var.namespace
  environment = var.environment
}

# TODO: convert to just creating a single policy
resource "aws_s3_bucket_policy" "input_policy" {
  for_each = toset(var.s3_access_principals)
  bucket = module.input_bucket[0].bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:*"],
        Resource = [
          module.input_bucket[0].bucket_arn,
          "${module.input_bucket[0].bucket_arn}/*"
        ],
        Principal = {
          AWS = each.key
        }
      }
    ]
  })
}
