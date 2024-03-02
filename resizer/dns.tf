
data "aws_route53_zone" "main" {
  count = length(local.domain_name) > 0 ? 1 : 0
  name         = local.domain_name
  private_zone = false
}

resource "aws_route53_record" "main" {
  count = local.cloudfront_count > 0 ? length(local.all_host_names) : 0
  zone_id = data.aws_route53_zone.main[0].id
  name    = local.all_host_names[count.index]
  type    = "A"

  alias {
    name = aws_cloudfront_distribution.main[0].domain_name
    zone_id = aws_cloudfront_distribution.main[0].hosted_zone_id
    evaluate_target_health = false
  }
}
