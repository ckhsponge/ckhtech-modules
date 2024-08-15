data aws_iam_policy_document sender {
  statement {
    actions = ["ses:SendEmail"]
    resources = concat(
      [aws_ses_domain_identity.main.arn],
      length(var.forward_to) > 0 ? ["arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.main.account_id}:identity/${var.forward_to}"] : []
    )
#    resources = ["arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.main.account_id}:identity/${var.domain}"]
  }
}

resource aws_iam_policy sender {
  name = "${local.canonical_name}-ses-sender"
  policy = data.aws_iam_policy_document.sender.json
}
