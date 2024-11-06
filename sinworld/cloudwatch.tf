data aws_iam_policy_document cloudwatch_put_metric_data {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_put_metric_data_policy" {
  name        = "cloudwatch-put-metric-data-policy"
  description = "Policy to allow CloudWatch PutMetricData"

  policy = data.aws_iam_policy_document.cloudwatch_put_metric_data.json
}
