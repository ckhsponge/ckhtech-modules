output "api_id" {
  value = aws_apigatewayv2_api.websocket.id
}

output "stage_invoke_url" {
  value = aws_apigatewayv2_stage.websocket.invoke_url
}

output "execution_arn" {
  value = aws_apigatewayv2_api.websocket.execution_arn
}

output "websocket_endpoint" {
  value = "https://${aws_apigatewayv2_api.websocket.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_apigatewayv2_stage.websocket.name}"
}

output "manage_connections_policy_arn" {
  value = aws_iam_policy.websocket_manage_connections.arn
}

output "stage_name" {
  value = var.stage_name
}
