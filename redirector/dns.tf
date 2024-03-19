
data "aws_route53_zone" "main" {
  name         = compact([var.route53_domain_name,local.domain_root])[0]
  private_zone = false
}

data aws_acm_certificate main {
  domain = compact([var.certificate_domain_name,local.domain_root])[0]
}

resource "aws_route53_record" "main" {
  count = length(var.redirect_host_names)
  zone_id = data.aws_route53_zone.main.id
  name    = var.redirect_host_names[count.index]
  type    = "A"

  alias {
    name = aws_cloudfront_distribution.main.domain_name
    zone_id = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
