output from {
  value = var.from
}

output "smtp_username" {
  value = aws_iam_access_key.smtp_user.id
}

output "smtp_password" {
  sensitive = true
  value = aws_iam_access_key.smtp_user.ses_smtp_password_v4
}

output smtp_endpoint {
  value = "email-smtp.${var.aws_region}.amazonaws.com"
}

output sender_policy_arn {
  value = aws_iam_policy.sender.arn
}
