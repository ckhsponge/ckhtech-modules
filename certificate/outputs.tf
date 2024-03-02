output domain_name {
  value = aws_acm_certificate.main.domain_name
}

output arn {
  value = aws_acm_certificate.main.arn
}
