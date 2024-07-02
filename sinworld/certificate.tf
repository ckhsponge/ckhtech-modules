locals {
  domain_certificate = compact([var.domain_certificate,var.domain_base])[0]
  domain_route53_zone = compact([var.domain_route53_zone,var.domain_base])[0]
}

module certificate {
  depends_on = [aws_route53_zone.main]
  count = var.create_certificate ? 1 : 0
  source = "../certificate"
  domain_name = local.domain_certificate
  domain_name_route53_zone = local.domain_route53_zone
}
