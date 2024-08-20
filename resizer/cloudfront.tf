locals {
  cloudfront_count = var.create_cloudfront ? 1 : 0
  cloudfront_distribution_arn = var.create_cloudfront ? aws_cloudfront_distribution.main[0].arn : var.cloudfront_distribution_arn
}

resource "aws_cloudfront_distribution" "main" {
  count = local.cloudfront_count

  tags = {
    name = local.canonical_name
  }

  origin_group {
    origin_id = "main"

    failover_criteria {
      status_codes = [400, 403, 404, 416, 500, 502, 503, 504]
    }

    member {
      origin_id = "s3"
    }

    member {
      origin_id = "func"
    }
  }

  origin {
    domain_name              = data.aws_s3_bucket.files.bucket_regional_domain_name
    origin_id                = "s3"
    #    origin_path = var.origin_path
    origin_access_control_id = aws_cloudfront_origin_access_control.s3[0].id
  }

  #  custom_error_response {
  #    error_code = "404"
  #    response_code = var.response_code_404 # instead of returning 404 return this code
  #    response_page_path = var.response_page_path_404
  #  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = local.all_host_names
  #  default_root_object = var.default_root_object

  origin {
    domain_name = replace(replace(aws_apigatewayv2_stage.lambda.invoke_url, "https://", ""), "/", "")
    origin_id   = "func"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
      origin_protocol_policy = "https-only"
    }
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "main"
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true #var.compress
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main[0].id
    cache_policy_id            = aws_cloudfront_cache_policy.main[0].id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      //      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.main[0].arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "s3" {
  count                             = local.cloudfront_count
  name                              = "access-control-${var.host_name}"
  description                       = "Access Control ${var.host_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" main {
  count = local.cloudfront_count
  name = "${local.canonical_name}-resizer-headers-policy"

  cors_config {
    access_control_allow_credentials = false
    access_control_allow_headers {
      items = ["Location","Access-Control-Allow-Origin"]
    }
    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS"]
    }
    access_control_allow_origins {
      items = var.cloudfront_cors_origins
    }
    origin_override = true
  }

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      override     = true
      frame_option = "DENY"
    }

    referrer_policy {
      override        = true
      referrer_policy = "same-origin"
    }

    strict_transport_security {
      override                   = true
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = false
    }

    xss_protection {
      override   = true
      mode_block = true
      protection = true
    }
  }
}

resource "aws_cloudfront_cache_policy" "main" {
  count = local.cloudfront_count
  name        = "${local.canonical_name}-resizer-cache-policy"
  max_ttl     = 604800 // week
  default_ttl = 86400 // day
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}
