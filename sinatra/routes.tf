data "aws_route53_zone" "main" {
  name = compact([var.route53_domain_name, local.domain_base])[0]
}

data aws_acm_certificate main {
  domain = compact([var.certificate_domain_name, local.domain_base])[0]
}

resource "aws_apigatewayv2_domain_name" "main" {
  domain_name = var.host_name

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.main.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
