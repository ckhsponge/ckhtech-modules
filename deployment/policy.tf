
data aws_caller_identity main {}
data "aws_partition" "current" {}

data aws_s3_bucket static {
  bucket = var.static_bucket_name
}

locals {
  # the IAM resource definitions that codebuild or codepipeline could ever need access to
  bucket_iam_resources = concat(
    [module.codepipline_bucket.bucket_arn, "${module.codepipline_bucket.bucket_arn}/*"],
      length(module.input_bucket) > 0 ? [module.input_bucket[0].bucket_arn, "${module.input_bucket[0].bucket_arn}/*"] : [],
      length(var.static_bucket_name) > 0 ? [data.aws_s3_bucket.static.arn, "${data.aws_s3_bucket.static.arn}/*"] : [],
  )
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${local.canonical_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${local.canonical_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.name

  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:*", # TODO: limit to needed resources
      # "codedeploy:*", # TODO: limit to needed resources
      "cloudwatch:*",
      "logs:*",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = ["s3:List*", "s3:Get*", "s3:Put*", "s3:DeleteObject" ]
    resources = local.bucket_iam_resources
  }
  dynamic "statement" {
    for_each = aws_codestarconnections_connection.github
    content {
      actions = [
        "codestar-connections:UseConnection",
        "codestar-connections:GetConnection",
        "codestar-connections:ListConnections",
      ]
      resources = [statement.value.arn]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${local.canonical_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    actions = ["logs:*"]
    resources = ["*"]
  }
  statement {
    actions = ["s3:List*", "s3:Get*", "s3:Put*", "s3:DeleteObject" ]
    resources = local.bucket_iam_resources
  }
  statement {
    actions = [
      "lambda:UpdateFunctionCode",
    ]
    resources = [for l in data.aws_lambda_function.main : l.arn]
  }
}
