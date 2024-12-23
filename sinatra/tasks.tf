locals {
  task_function_names_map = {for idx, n in var.task_names : n => "${var.service}-${var.name}-task-${n}"}
  task_function_names = values(local.task_function_names_map) 
}

resource "aws_lambda_function" "task" {
  for_each = local.task_function_names_map
  function_name = each.value

  runtime = var.lambda_runtime
  handler = "${var.task_handler_base}.${each.key}"

  filename = var.lambda_filename
  source_code_hash = var.source_code_hash

  timeout = 900 # 900s = 15 minutes, the max allowed

  role = aws_iam_role.lambda_exec.arn
  environment {
    variables = local.lamda_environment_variables
  }

  memory_size = var.lambda_memory_size

  lifecycle {
    ignore_changes = [source_code_hash] # update code using CLI or other method
  }
}

resource "aws_cloudwatch_log_group" "task" {
  for_each = aws_lambda_function.task
  name = "/aws/lambda/${aws_lambda_function.task[each.key].function_name}"

  retention_in_days = 30
}
