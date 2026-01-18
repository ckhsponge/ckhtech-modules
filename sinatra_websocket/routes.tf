resource "aws_apigatewayv2_route" "websocket_default" {
  api_id = aws_apigatewayv2_api.websocket.id
  route_key = "$default"
  target = "integrations/${aws_apigatewayv2_integration.websocket.id}"
}

resource "aws_apigatewayv2_route_response" "websocket_default" {
  api_id = aws_apigatewayv2_api.websocket.id
  route_id = aws_apigatewayv2_route.websocket_default.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "websocket_connect" {
  api_id = aws_apigatewayv2_api.websocket.id
  route_key = "$connect"
  target = "integrations/${aws_apigatewayv2_integration.websocket.id}"
}

resource "aws_apigatewayv2_route_response" "websocket_connect" {
  api_id = aws_apigatewayv2_api.websocket.id
  route_id = aws_apigatewayv2_route.websocket_connect.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "websocket_disconnect" {
  api_id = aws_apigatewayv2_api.websocket.id
  route_key = "$disconnect"
  target = "integrations/${aws_apigatewayv2_integration.websocket.id}"
}

resource "aws_apigatewayv2_route_response" "websocket_disconnect" {
  api_id = aws_apigatewayv2_api.websocket.id
  route_id = aws_apigatewayv2_route.websocket_disconnect.id
  route_response_key = "$default"
}