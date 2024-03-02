

resource aws_lambda_function resizer {
  function_name    = local.canonical_name
  handler          = "resizer.Resizer.process"
  runtime          = "ruby3.2"
  role             = aws_iam_role.lambda.arn
  filename         = data.archive_file.app.output_path
  source_code_hash = data.archive_file.app.output_base64sha256
  publish          = true
  timeout          = 30
  memory_size      = 2048 # large helps CPU!!! Upping to 4096 might help more but we are limited to 3008.
  environment {
    variables = {
      BUCKET_NAME = var.files_bucket
      HOST_NAME = var.host_name
      ORIGINAL_DIRECTORY = var.original_directory
      SOURCE_DIRECTORY = var.source_directory
      DESTINATION_DIRECTORY = var.destination_directory
      ORIGINAL_FORMATS = jsonencode(var.original_formats)
      OUTPUT_FORMATS = jsonencode(var.output_formats)
      SIZES_BY_NAME = jsonencode(var.sizes_by_name)
    }
  }
  layers           = [
    data.aws_lambda_layer_version.magick.arn
  ]
  tags             = {}
}

data aws_lambda_layer_version magick {
#  depends_on = [aws_serverlessapplicationrepository_cloudformation_stack.magick]
  layer_name = "image-magick"
}

data "archive_file" "app" {
  type        = "zip"
  source_dir  = "${path.module}/app"
  output_path = "${path.module}/app.zip"
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}


data "aws_iam_policy_document" "files_s3_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
      "s3:PutObject"
    ]
    resources = ["${data.aws_s3_bucket.files.arn}/*"]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [data.aws_s3_bucket.files.arn]
  }
  statement {
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" lambda_files_s3 {
  name   = "${local.canonical_name}-lambda-files"
  policy = data.aws_iam_policy_document.files_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "additional" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_files_s3.arn
}

resource "aws_iam_role" "lambda" {
  name               = "${local.canonical_name}-iam-rolelambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = {}
}
