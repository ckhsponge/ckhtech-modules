variable "aws_region" {
  type = string
}

variable "service" {
  type = string
}

variable "websocket_function_name" {
  type = string
}

variable "stage_name" {
  type = string
  default = "cable"
}