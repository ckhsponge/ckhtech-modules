resource aws_sns_topic email {
  count = var.sns_enabled ? 1 : 0
  name = "${local.canonical_name}-email-receive"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  count = length(aws_sns_topic.email)
  topic_arn = aws_sns_topic.email[count.index].arn
  protocol  = "email"
  endpoint  = var.forward_to
}

resource "aws_ses_receipt_rule" "sns" {
  count = length(aws_sns_topic.email)
  name          = local.ses_receipt_rule_name_sns
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  #  recipients    = ["karen@example.com"]
  enabled       = true
  scan_enabled  = true

  #  add_header_action {
  #    header_name  = "Custom-Header"
  #    header_value = "Added by SES"
  #    position     = 1
  #  }

  sns_action {
    position    = 1
    topic_arn   = aws_sns_topic.email[count.index].arn
  }
}
