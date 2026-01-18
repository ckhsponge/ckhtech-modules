data "aws_caller_identity" "current" {}

resource "aws_apigatewayv2_api" "websocket" {
  name = "${var.service}-websocket"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "websocket" {
  depends_on = [aws_iam_role_policy_attachment.api_gateway_cloudwatch, aws_api_gateway_account.this]
  api_id = aws_apigatewayv2_api.websocket.id
  name = var.stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.websocket_api.arn
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
  name = "/aws/api_gw/${var.service}-websocket"
  retention_in_days = 30
}

resource "aws_apigatewayv2_integration" "websocket" {
  api_id = aws_apigatewayv2_api.websocket.id
  integration_uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.websocket_function_name}/invocations"
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  connection_type = "INTERNET"
}

resource "aws_lambda_permission" "websocket" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = var.websocket_function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.websocket.execution_arn}/*/*"
}