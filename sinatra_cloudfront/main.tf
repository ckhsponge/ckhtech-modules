locals {
  domain_split = split(".",var.host_name)
  domain_split_length = length(local.domain_split)
  domain_name = "${local.domain_split[local.domain_split_length - 2]}.${local.domain_split[local.domain_split_length - 1]}"
  canonical_name = "${var.service}-${var.name}"
  allowed_methods = concat(["GET", "HEAD", "OPTIONS"], var.allow_post ? ["PUT", "PATCH", "POST", "DELETE"] : [])
}

locals {
  cloudfront_origin_id = "${var.host_name}-${random_string.origin_id.result}"
  cloudfront_origin_id_static = "${local.cloudfront_origin_id}-static"
  cloudfront_origin_id_files = "${local.cloudfront_origin_id}-files"
  cloudfront_origin_id_files_group = "${local.cloudfront_origin_id}-files-group"
  cloudfront_origin_id_files_failover = "${local.cloudfront_origin_id}-files-failover"
  cloudfront_origin_id_websocket = "${local.cloudfront_origin_id}-websocket"
}

resource "random_string" "origin_id" {
  length = 16
  special = false
  numeric = true // NOT numeric anymore
}

data aws_acm_certificate main {
  domain = compact([var.certificate_domain_name,local.domain_name])[0]
}

locals {
  all_host_names = concat([var.host_name],var.additional_host_names)
}

resource "aws_cloudfront_distribution" "main" {
  tags = {
    name = local.canonical_name
  }
  origin {
    domain_name = var.origin_domain_name //aws_s3_bucket.main.bucket_regional_domain_name
    origin_id   = local.cloudfront_origin_id
    origin_path = var.origin_path
    origin_access_control_id = length(aws_cloudfront_origin_access_control.main) > 0 ? aws_cloudfront_origin_access_control.main[0].id : null

    #    s3_origin_config {
#      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
#    }
    dynamic custom_origin_config {
      for_each = var.origin_is_s3 ? [] : [0]
      content {
        http_port = 80
        https_port = 443
        origin_ssl_protocols = ["TLSv1.2"]
        origin_protocol_policy = "https-only"
      }
    }
  }

  custom_error_response {
    error_code = "404"
    response_code = var.response_code_404 # instead of returning 404 return this code
    response_page_path = var.response_page_path_404
  }

  enabled             = true
  is_ipv6_enabled     = true

  aliases = local.all_host_names
  default_root_object = var.default_root_object

  default_cache_behavior {
    allowed_methods  = local.allowed_methods
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.cloudfront_origin_id

    viewer_protocol_policy = "redirect-to-https"
    compress               = var.compress
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default.id
    cache_policy_id            = aws_cloudfront_cache_policy.default.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.default.id
  }

  dynamic "ordered_cache_behavior" {
    for_each = aws_cloudfront_function.matched
    content {
      path_pattern     = var.function_path_pattern
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = local.cloudfront_origin_id

      viewer_protocol_policy = "redirect-to-https"

      function_association {
        event_type   = "viewer-request"
        function_arn = ordered_cache_behavior.value.arn
      }
      response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
      cache_policy_id            = aws_cloudfront_cache_policy.function.id
    }
  }

#  alternate paths can be mapped to files in s3 aka public
  dynamic origin {
    for_each = length(var.static_s3_regional_domain_name) > 0 && length(var.static_s3_origin_paths) > 0 ? [0] : []
    content {
      domain_name = var.static_s3_regional_domain_name //aws_s3_bucket.main.bucket_regional_domain_name
      origin_id   = "${local.cloudfront_origin_id_static}"
      origin_path = var.static_s3_origin_path_root
      origin_access_control_id = length(aws_cloudfront_origin_access_control.alternate) > 0 ? aws_cloudfront_origin_access_control.alternate[0].id : null
    }
  }

#  behaviors that use the static paths
  dynamic ordered_cache_behavior {
    for_each =  length(var.static_s3_regional_domain_name) > 0 ? var.static_s3_origin_paths : []
    content {
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      path_pattern           = "${ordered_cache_behavior.value}*"
      target_origin_id       = "${local.cloudfront_origin_id_static}"
      viewer_protocol_policy = "redirect-to-https"
      compress = var.compress
      response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
      cache_policy_id            = aws_cloudfront_cache_policy.static.id
    }
  }

  dynamic "origin_group" {
    for_each = var.has_files_failover ? [0] : []
    content {
      origin_id = local.cloudfront_origin_id_files_group

      failover_criteria {
        status_codes = [400, 403, 404, 416, 500, 502, 503, 504]
      }

      member {
        origin_id = local.cloudfront_origin_id_files
      }

      member {
        origin_id = local.cloudfront_origin_id_files_failover
      }
    }
  }

  dynamic origin {
    for_each = var.has_files_bucket ? [0] : []
    content {
      domain_name = var.files_s3_regional_domain_name //aws_s3_bucket.main.bucket_regional_domain_name
      origin_id   = local.cloudfront_origin_id_files
      origin_path = var.files_s3_origin_path
      origin_access_control_id = length(aws_cloudfront_origin_access_control.files) > 0 ? aws_cloudfront_origin_access_control.files[0].id : null
    }
  }

  dynamic origin {
    for_each = var.has_files_failover ? [0] : []
    content {
      domain_name = var.files_failover_domain_name
      origin_id   = local.cloudfront_origin_id_files_failover
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_protocol_policy = "https-only"
      }
    }
  }

  dynamic ordered_cache_behavior {
    for_each = var.has_files_bucket ? [0] : []
    content {
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      path_pattern           = "${var.files_s3_path_pattern}*"
      target_origin_id       = var.has_files_failover ? local.cloudfront_origin_id_files_group : local.cloudfront_origin_id_files
      viewer_protocol_policy = "redirect-to-https"
      compress = var.compress
      response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
      cache_policy_id            = aws_cloudfront_cache_policy.files.id
    }
  }

  dynamic origin {
    for_each = var.has_websocket ? [0] : []
    content {
      domain_name = var.websocket_domain_name
      origin_id = local.cloudfront_origin_id_websocket
      custom_origin_config {
        http_port = 80
        https_port = 443
        origin_ssl_protocols = ["TLSv1.2"]
        origin_protocol_policy = "https-only"
      }
    }
  }

  dynamic ordered_cache_behavior {
    for_each = var.has_websocket ? [0] : []
    content {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/${var.websocket_stage_name}"
      target_origin_id = local.cloudfront_origin_id_websocket
      viewer_protocol_policy = "redirect-to-https"
      compress = false
      response_headers_policy_id = aws_cloudfront_response_headers_policy.default.id
      cache_policy_id = aws_cloudfront_cache_policy.websocket[0].id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.websocket[0].id
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
//      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.main.arn
    ssl_support_method = "sni-only"
  }
}

resource "aws_cloudfront_function" "matched" {
  count = length(var.function_code) > 0 ? 1 : 0
  name    = replace("${var.host_name}-matched", ".", "-")
  runtime = "cloudfront-js-1.0"
#  comment = "my function"
  publish = true
  code    = var.function_code
}

resource "aws_cloudfront_origin_access_control" "main" {
  count = var.origin_is_s3 ? 1 : 0
  name                              = "access-control-${var.host_name}"
  description                       = "Access Control ${var.host_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "alternate" {
  count = length(var.static_s3_origin_paths) > 0 ? 1 : 0
  name                              = "access-control-${var.host_name}-alternate"
  description                       = "Access Control ${var.host_name} alternate"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "files" {
  count = var.has_files_bucket ? 1 : 0
  name                              = "access-control-${var.host_name}-files"
  description                       = "Access Control ${var.host_name} files"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
