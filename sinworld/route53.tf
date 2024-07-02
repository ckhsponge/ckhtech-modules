resource "aws_route53_zone" "main" {
  count = var.create_route53_zone ? 1 : 0
  name = var.domain_base
}
