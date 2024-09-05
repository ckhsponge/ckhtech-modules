locals {
  canonical_name = "${var.service}-${var.name}"
}

data aws_lambda_function main {
  function_name = var.lambda_function_name
}
