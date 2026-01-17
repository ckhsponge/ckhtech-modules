

locals {
  lamda_environment_variables = merge(
    var.environment_variables,
    var.create_websocket ? {
      WEBSOCKET_ENDPOINT = "https://${aws_apigatewayv2_api.websocket[0].id}.execute-api.${var.aws_region}.amazonaws.com/${aws_apigatewayv2_stage.websocket[0].name}"
    } : {}
  )
}

resource "aws_lambda_function" "sinatra" {
  function_name = local.function_name

  runtime = var.lambda_runtime
  handler = var.sinatra_handler

  filename = var.lambda_filename
  source_code_hash = var.source_code_hash

  role = aws_iam_role.lambda_exec.arn
  environment {
    variables = local.lamda_environment_variables
  }

  memory_size = var.lambda_memory_size

  lifecycle {
    ignore_changes = [source_code_hash] # update code using CLI or other method
  }
}

resource "aws_cloudwatch_log_group" "sinatra" {
  name = "/aws/lambda/${aws_lambda_function.sinatra.function_name}"

  retention_in_days = 30
}

data aws_iam_policy_document lambda_exec {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.service}-lambda"

  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

locals {
  additional_lambda_policy_arns = concat(
    var.additional_lambda_policy_arns,
    var.create_websocket ? [aws_iam_policy.websocket_manage_connections[0].arn] : []
  )
}

resource "aws_iam_policy" "websocket_manage_connections" {
  count = var.create_websocket ? 1 : 0
  name = "${var.service}-websocket-manage-connections"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "execute-api:ManageConnections"
        Resource = "${aws_apigatewayv2_api.websocket[0].execution_arn}/*/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "additional" {
  count = length(local.additional_lambda_policy_arns)
  role       = aws_iam_role.lambda_exec.name
  policy_arn = local.additional_lambda_policy_arns[count.index]
}
