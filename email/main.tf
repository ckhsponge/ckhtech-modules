locals {
  canonical_name = "${var.service}-${var.name}"
  ses_receipt_rule_name_bucket = "${local.canonical_name}-rule-bucket"
  ses_receipt_rule_name_sns = "${local.canonical_name}-rule-sns"
  ses_receipt_rule_name_lambda = "${local.canonical_name}-rule-lambda"
  smtp_user = "${local.canonical_name}-smtp"
}
data aws_caller_identity main {}

data aws_route53_zone main {
  name = var.domain
}

# SES Domain Identity
resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

resource "aws_ses_domain_mail_from" "mx" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mx.${aws_ses_domain_identity.main.domain}" # could be bounce.*
}

# feedback Route53 MX record
resource "aws_route53_record" "ses_domain_mail_from_mx" {
  zone_id = data.aws_route53_zone.main.id
  name    = aws_ses_domain_mail_from.mx.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"] # Change to the region in which `aws_ses_domain_identity.main` is created
}

# feedback Route53 TXT record for SPF
resource "aws_route53_record" "ses_domain_mail_from_txt" {
  zone_id = data.aws_route53_zone.main.id
  name    = aws_ses_domain_mail_from.mx.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = data.aws_route53_zone.main.id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

resource "aws_ses_domain_identity_verification" "main" {
  domain = aws_ses_domain_identity.main.id

  depends_on = [aws_route53_record.amazonses_verification_record]
}

resource "aws_ses_email_identity" "main" {
  count = length(var.email_identities)
  email = "${var.email_identities[count.index]}@${aws_ses_domain_identity.main.domain}"
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.main.id
  name    = "${aws_ses_domain_dkim.main.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.main.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_ses_configuration_set" "main" {
  name = local.canonical_name
  reputation_metrics_enabled = true
}

resource "aws_route53_record" "inbound" {
  zone_id = data.aws_route53_zone.main.id
  name    = var.domain
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${var.aws_region}.amazonaws.com"]
}

resource "aws_ses_email_identity" "recipient" {
  count = length(var.forward_to) > 0 ? 1 : 0
  email = var.forward_to
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "${local.canonical_name}-rule-set"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  depends_on = [aws_ses_receipt_rule.bucket, aws_ses_receipt_rule.sns, aws_ses_receipt_rule.lambda]
}
