module input_bucket {
  count       = 1
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

    actions = ["s3:List*", "s3:Get*", "s3:Put*", "s3:DeleteObject"]

    resources = [
      module.input_bucket[0].bucket_arn,
      "${module.input_bucket[0].bucket_arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = var.s3_access_principals
    }
  }

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [module.input_bucket[0].bucket_arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${var.aws_region}:${data.aws_caller_identity.main.account_id}:trail/${local.cloudtrail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${module.input_bucket[0].bucket_arn}/${local.cloudtrail_prefix}/AWSLogs/${data.aws_caller_identity.main.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${var.aws_region}:${data.aws_caller_identity.main.account_id}:trail/${local.cloudtrail_name}"]
    }
  }
}

locals {
  cloudtrail_name = "deployment-input-${var.service}-${var.name}"
  cloudtrail_prefix = "cloudtrail"
}

# This cloudtrail will create the events needed for the cloudwatch event rule that starts the pipeline
resource "aws_cloudtrail" "cloudtrail" {
  depends_on = [aws_s3_bucket_policy.input_policy]
  name                          = local.cloudtrail_name
  s3_bucket_name                = module.input_bucket[0].bucket_name
  s3_key_prefix                 = local.cloudtrail_prefix
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = false
  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = false
    data_resource {
      type = "AWS::S3::Object"
      values = ["arn:aws:s3:::${module.input_bucket[0].bucket_name}/${var.repository_zip_filename}"]
    }
  }
}
