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

resource "aws_s3_bucket_policy" "input_policy" {
  count = length(module.input_bucket)
  bucket = module.input_bucket[0].bucket_name

  policy = data.aws_iam_policy_document.input_bucket_policy.json
}

data "aws_iam_policy_document" "input_bucket_policy" {
  statement {
    effect = "Allow"

    actions = ["s3:List*", "s3:Get*", "s3:Put*", "s3:DeleteObject" ]

    resources = [
      module.input_bucket[0].bucket_arn,
      "${module.input_bucket[0].bucket_arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = var.s3_access_principals
    }
  }
}
