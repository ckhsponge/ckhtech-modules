locals {
  canonical_name       = "${var.service}-${var.name}"
  cloudfront_origin_id = "${var.redirect_host_names[0]}-${random_string.origin_id.result}"
  host_split           = split(".", var.host_name)
  host_split_length    = length(local.host_split)
  domain_root          = "${local.host_split[local.host_split_length - 2]}.${local.host_split[local.host_split_length - 1]}"
}

locals {
  function_code = <<-EOF
function handler(event) {
  var request = event.request;
  var response = {
    statusCode: 301,
    statusDescription: 'Moved Permanently',
    headers: {
      location: {
        value: `https://${var.host_name}$${request.uri}`
      },
    },
  };

  return response;
}
EOF
}

resource "random_string" "origin_id" {
  length  = 16
  special = false
  numeric = true
}

data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "main" {
  tags = {
    name = local.canonical_name
  }
  origin {
    domain_name = "totallydoesntexistdomain.com"
    origin_id   = local.cloudfront_origin_id
    origin_path = ""
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.1"]
      origin_protocol_policy = "https-only"
    }
  }

  custom_error_response {
    error_code         = "404"
    response_code      = var.response_code_404 # instead of returning 404 return this code
    response_page_path = var.response_page_path_404
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = var.redirect_host_names

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.cloudfront_origin_id

    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.matched.arn
      #      lambda_arn   = aws_cloudfront_function.matched.arn
    }
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id #aws_cloudfront_cache_policy.default.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.main.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_function" "matched" {
  name    = replace("${local.canonical_name}-matched", ".", "-")
  runtime = "cloudfront-js-1.0"
  #  comment = "my function"
  publish = true
  code    = local.function_code
}


resource "aws_cloudfront_response_headers_policy" main {
  name = "${local.canonical_name}-resizer-headers-policy"

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
      access_control_max_age_sec = 63072000 // 2 years, requirement is >1 year for preload
      include_subdomains         = true
      preload                    = var.strict_transport_security_preload
    }

    xss_protection {
      override   = true
      mode_block = true
      protection = true
    }
  }
}
