module email_bucket {
  source = "../s3"
  identifier  = "emails-ses"
  namespace   = var.namespace
  environment = var.environment
#  encrypted = false
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${module.email_bucket.bucket_arn}/*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.main.account_id]
      variable = "AWS:SourceAccount"
    }
    condition {
      test     = "StringEquals"
      values   = ["${aws_ses_receipt_rule_set.main.arn}:receipt-rule/${local.ses_receipt_rule_name_bucket}"]
      variable = "AWS:SourceArn"
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  #  count = length(var.additional_s3_policy_principals) > 0 ? 1 : 0
  bucket = module.email_bucket.bucket_name
  policy = data.aws_iam_policy_document.s3_policy.json
}


resource "aws_ses_receipt_rule" "bucket" {
  name          = local.ses_receipt_rule_name_bucket
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  #  recipients    = ["karen@example.com"]
  enabled       = true
  scan_enabled  = true
  depends_on = [aws_s3_bucket_policy.main]

  #  add_header_action {
  #    header_name  = "Custom-Header"
  #    header_value = "Added by SES"
  #    position     = 1
  #  }

  s3_action {
    bucket_name = module.email_bucket.bucket_name
    object_key_prefix = var.bucket_object_key_prefix
    position    = 1
  }
}

data "aws_iam_policy_document" "bucket_key_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.main.account_id}:root"]
    }
    actions = ["kms:*"]
    resources = ["*"]
  }
  statement {

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.main.account_id}:root"]
    }
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [
        "${aws_ses_receipt_rule_set.main.arn}:receipt-rule/${local.ses_receipt_rule_name_bucket}",
        "${aws_ses_receipt_rule_set.main.arn}:receipt-rule/${local.ses_receipt_rule_name_lambda}",
        "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.main.account_id}:function:${local.lambda_function_name}"
      ]
      variable = "AWS:SourceArn"
    }
  }

}

resource "aws_kms_key" "bucket" {
  count = var.encrypt_bucket ? 1 : 0
  description = "This key is used to encrypt bucket ${module.email_bucket.bucket_name}"
  policy = data.aws_iam_policy_document.bucket_key_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  count = length(aws_kms_key.bucket)
  bucket = module.email_bucket.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket[count.index].arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
