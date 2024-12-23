locals {
  job_queue_function_name = module.sinatra.lambda_task_function_names_by_task[var.job_queue_task_name]
}

resource "aws_sqs_queue" "job" {
  count                      = var.create_job_queue ? 1 : 0
  name                       = "${var.service}-${var.environment}-job-queue"
  content_based_deduplication = false # use a deduplication id instead
  visibility_timeout_seconds = 900
}

resource "aws_lambda_permission" "job_lambda_permission" {
  count         = var.create_job_queue ? 1 : 0
  depends_on = [module.sinatra]
  statement_id  = "AllowSQSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = local.job_queue_function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.job[0].arn
}

resource "aws_lambda_event_source_mapping" "job_lambda_event_source_mapping" {
  count            = var.create_job_queue ? 1 : 0
  depends_on = [module.sinatra]
  event_source_arn = aws_sqs_queue.job[0].arn
  function_name    = local.job_queue_function_name
  enabled          = true
  batch_size       = 10
}


data "aws_iam_policy_document" "job_sqs_policy_document" {
  statement {
    actions = [
      "sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:GetQueueUrl"
    ]
    resources = [length(aws_sqs_queue.job) > 0 ? aws_sqs_queue.job[0].arn : ""]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "job_sqs_policy" {
  count       = var.create_job_queue ? 1 : 0
  name        = "${var.service}-${var.environment}-job-sqs-policy"
  description = "Policy allowing creating, reading, and writing messages to the job SQS queue"
  policy      = data.aws_iam_policy_document.job_sqs_policy_document.json
}
