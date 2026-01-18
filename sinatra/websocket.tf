
module "websocket" {
  count = var.create_websocket ? 1 : 0
  source = "../sinatra_websocket"
  
  aws_region = var.aws_region
  service = var.service
  websocket_function_name = var.websocket_function_name
}
