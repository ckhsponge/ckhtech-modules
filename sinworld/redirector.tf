module cloudfront_redirect {
  count = length(var.redirect_host_names) > 0 ? 1 : 0
  depends_on = [module.certificate]
  source = "../redirector"

  aws_region = var.aws_region
  service = var.service
  redirect_host_names = var.redirect_host_names
  host_name = var.host_name
  certificate_domain_name = local.domain_certificate
  route53_domain_name = var.domain_route53_zone
}
