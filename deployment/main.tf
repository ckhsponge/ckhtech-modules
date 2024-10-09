locals {
  canonical_name = "${var.service}-${var.name}"
}

data aws_lambda_function main {
  for_each = toset(var.lambda_function_names)
  function_name =  each.value
}
