resource "aws_lambda_function" "websocket" {
  count = var.create_websocket ? 1 : 0
  function_name = "${local.function_name}-websocket"

  runtime = var.lambda_runtime
  handler = var.websocket_handler

  filename = var.lambda_filename
  source_code_hash = var.source_code_hash

  role = aws_iam_role.lambda_exec.arn
  environment {
    variables = local.lamda_environment_variables
  }

  memory_size = var.lambda_memory_size

  lifecycle {
    ignore_changes = [source_code_hash]
  }
}

resource "aws_cloudwatch_log_group" "websocket" {
  count = var.create_websocket ? 1 : 0
  name = "/aws/lambda/${aws_lambda_function.websocket[0].function_name}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_api" "websocket" {
  count = var.create_websocket ? 1 : 0
  name = "${var.service}-websocket"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "websocket" {
  depends_on = [aws_iam_role_policy_attachment.api_gateway_cloudwatch, aws_api_gateway_account.this]
  count = var.create_websocket ? 1 : 0
  api_id = aws_apigatewayv2_api.websocket[0].id
  name = "cable"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.websocket_api[0].arn
    format = jsonencode({
      requestId = "$context.requestId"
      sourceIp = "$context.identity.sourceIp"
      requestTime = "$context.requestTime"
      protocol = "$context.protocol"
      routeKey = "$context.routeKey"
      status = "$context.status"
      responseLength = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_cloudwatch_log_group" "websocket_api" {
  count = var.create_websocket ? 1 : 0
  name = "/aws/api_gw/${var.service}-websocket"
  retention_in_days = 30
}

resource "aws_apigatewayv2_integration" "websocket" {
  count = var.create_websocket ? 1 : 0
  api_id = aws_apigatewayv2_api.websocket[0].id
  integration_uri = aws_lambda_function.websocket[0].invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "websocket_default" {
  count = var.create_websocket ? 1 : 0
  api_id = aws_apigatewayv2_api.websocket[0].id
  route_key = "$default"
  target = "integrations/${aws_apigatewayv2_integration.websocket[0].id}"
}

resource "aws_lambda_permission" "websocket" {
  count = var.create_websocket ? 1 : 0
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket[0].function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.websocket[0].execution_arn}/*/*"
}


### should the below 3 resource be somewhere more general?
resource "aws_iam_role" "api_gateway_cloudwatch" {
  count = var.create_websocket ? 1 : 0
  name = "websocket-api-gateway-cloudwatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  count = var.create_websocket ? 1 : 0
  role       = aws_iam_role.api_gateway_cloudwatch[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  count = var.create_websocket ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch[0].arn
}
