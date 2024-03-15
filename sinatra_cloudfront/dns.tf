
data "aws_route53_zone" "main" {
  name         = compact([var.route53_domain_name,local.domain_name])[0]
  private_zone = false
}

resource "aws_route53_record" "main" {
  count = length(local.all_host_names)
  zone_id = data.aws_route53_zone.main.id
  name    = local.all_host_names[count.index]
  type    = "A"

  alias {
    name = aws_cloudfront_distribution.main.domain_name
    zone_id = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
