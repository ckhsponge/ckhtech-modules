resource "aws_cloudfront_response_headers_policy" main {
  name = "${local.canonical_name}-resizer-headers-policy"

  cors_config {
    access_control_allow_credentials = false
    access_control_allow_headers {
      items = ["Location", "Access-Control-Allow-Origin"]
    }
    access_control_allow_methods {
      items = local.allowed_methods
    }
    access_control_allow_origins {
      items = var.cors_origins
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
      override           = true
      access_control_max_age_sec = 63072000 // 2 years, requirement is >1 year for preload
      include_subdomains = true
      preload            = var.strict_transport_security_preload
    }

    xss_protection {
      override   = true
      mode_block = true
      protection = true
    }
  }
}

resource "aws_cloudfront_response_headers_policy" default {
  name = "${local.canonical_name}-default-headers-policy"

  cors_config {
    access_control_allow_credentials = false
    access_control_allow_headers {
      items = ["Location", "Access-Control-Allow-Origin"]
    }
    access_control_allow_methods {
      items = local.allowed_methods
    }
    access_control_allow_origins {
      items = var.cors_origins
    }
    origin_override = true
  }

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      override     = false
      frame_option = "SAMEORIGIN"
    }

    content_security_policy {
      content_security_policy = "frame-ancestors 'none';"
      override                = false
    }

    referrer_policy {
      override        = true
      referrer_policy = "same-origin"
    }

    strict_transport_security {
      override           = true
      access_control_max_age_sec = 63072000 // 2 years, requirement is >1 year for preload
      include_subdomains = true
      preload            = var.strict_transport_security_preload
    }

    xss_protection {
      override   = true
      mode_block = true
      protection = true
    }
  }
}

resource "aws_cloudfront_cache_policy" "default" {
  name        = "${local.canonical_name}-default-cache-policy"
  max_ttl     = var.max_ttl
  default_ttl = var.default_ttl_main
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = var.cache_cookies ? "all" : "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = concat(["Host", "Origin", "Mirror"], var.additional_headers)
      }
    }
    query_strings_config {
      query_string_behavior = var.cache_query_string ? "all" : "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}


resource "aws_cloudfront_origin_request_policy" "default" {
  name = "${local.canonical_name}-default-origin-request-policy"

  cookies_config {
    cookie_behavior = var.forward_cookies ? "all" : "none"
  }

  query_strings_config {
    query_string_behavior = var.forward_query_string ? "all" : "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = concat(["Host", "Origin", "Content-Security-Policy", "X-Frame-Options"], var.additional_headers)
    }
  }

}

resource "aws_cloudfront_cache_policy" "static" {
  name        = "${local.canonical_name}-static-cache-policy"
  max_ttl     = var.max_ttl
  default_ttl = var.default_ttl_static
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
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "files" {
  name        = "${local.canonical_name}-files-cache-policy"
  max_ttl     = var.max_ttl
  default_ttl = var.default_ttl_files
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
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "function" {
  name        = "${local.canonical_name}-function-cache-policy"
  max_ttl     = var.max_ttl
  default_ttl = var.default_ttl_function
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = var.forward_cookies ? "all" : "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Host", "Origin"]
      }
    }
    query_strings_config {
      query_string_behavior = var.forward_query_string ? "all" : "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}
