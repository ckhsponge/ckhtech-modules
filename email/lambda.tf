locals {
  lambda_function_name = "emailForward"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${local.canonical_name}-email-receive-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  inline_policy {}
}

data aws_iam_policy_document lambda_policy {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "kms:*"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:GetObject",
      "ses:SendRawEmail"
    ]
    resources = [
      "${module.email_bucket.bucket_arn}/*",
      "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.main.account_id}:identity/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${local.canonical_name}-email-receive-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "additional" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "src.zip"
}

resource "aws_lambda_function" "email" {
  function_name    = local.lambda_function_name
  filename         = "src.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.lambda_runtime
  handler          = "lambda_function.lambda_handler"
  timeout          = 10

  environment {
    variables = {
      MailS3Bucket  = module.email_bucket.bucket_name
      MailS3Prefix  = var.bucket_object_key_prefix
      MailSender    = var.from
      MailRecipient = var.forward_to
      Region        = var.aws_region
    }
  }
}

resource "aws_lambda_permission" "allow_ses" {
  statement_id  = "AllowExecutionFromSES"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email.function_name
  principal     = "ses.amazonaws.com"
  source_arn    = "${aws_ses_receipt_rule_set.main.arn}:receipt-rule/${local.ses_receipt_rule_name_lambda}"
  #  qualifier     = aws_lambda_alias.test_alias.name
}

resource "aws_ses_receipt_rule" "lambda" {
  name          = local.ses_receipt_rule_name_lambda
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  #  recipients    = ["karen@example.com"]
  enabled       = true
  scan_enabled  = true
  depends_on    = [aws_lambda_permission.allow_ses]

  #  add_header_action {
  #    header_name  = "Custom-Header"
  #    header_value = "Added by SES"
  #    position     = 1
  #  }

  lambda_action {
    position     = 1
    function_arn = aws_lambda_function.email.arn
  }
}
