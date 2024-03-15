
data aws_caller_identity current {}

data "aws_iam_policy_document" "bucket_key_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["kms:*"]
    resources = ["*"]
  }
  statement {

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [var.cloudfront_distribution_arn]
      variable = "AWS:SourceArn"
    }
  }

}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = [
      "s3:GetObject",
      "s3:GetObjectTagging",
    ]
    resources = ["${var.bucket_arn}/*"]

    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      values   = [var.cloudfront_distribution_arn]
      variable = "AWS:SourceArn"
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [var.bucket_arn]

    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      values   = [var.cloudfront_distribution_arn]
      variable = "AWS:SourceArn"
    }
  }
}
