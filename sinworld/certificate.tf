locals {
  domain_certificate = length(var.domain_certificate) > 0 ? var.domain_certificate : var.domain_base
}

module certificate {
  count = var.create_certificate ? 1 : 0
  source = "../certificate"
  domain_name = local.domain_certificate
  domain_name_route53_zone = var.domain_route53_zone
}
