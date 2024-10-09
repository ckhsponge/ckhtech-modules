variable lambda_function_name {
  type = string
}


resource "aws_sqs_queue" "main" {
  name = "${var.lambda_function_name}_trigger_queue"
}

resource "aws_lambda_permission" "sqs_trigger_permission" {
  statement_id  = "AllowSQSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.main.arn
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = var.lambda_function_name
  enabled          = true
  batch_size       = 10
}

