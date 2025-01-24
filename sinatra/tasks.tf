locals {
  task_functions_map = {for f in var.task_lambda_functions : f.function_name => f}
  task_function_names = [for f in var.task_lambda_functions : f.function_name ]
  task_crons = flatten([for f in var.task_lambda_functions : [for c in f.crons : merge(c, {function_name = f.function_name})]])
  task_crons_map = {for c in local.task_crons : c.rule_name => c}
}

resource "aws_lambda_function" "task" {
  for_each = local.task_functions_map
  function_name = each.value.function_name

  runtime = var.lambda_runtime
  handler = each.value.handler

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

resource "aws_cloudwatch_event_rule" "task" {
  for_each = local.task_crons_map
  name = each.value.rule_name
  schedule_expression = each.value.schedule_expression
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
  for_each = local.task_crons_map
  rule = aws_cloudwatch_event_rule.task[each.key].name
  # target_id = "check_foo"
  arn = aws_lambda_function.task[each.value.function_name].arn
  input = each.value.input
}

resource "aws_lambda_permission" "task" {
  for_each = local.task_crons_map
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.task[each.key].arn
}
