resource "aws_cloudfront_cache_policy" "websocket" {
  count = var.has_websocket ? 1 : 0
  name = "${local.canonical_name}-websocket-cache-policy"
  max_ttl = 1
  default_ttl = 0
  min_ttl = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = false
    enable_accept_encoding_gzip = false
  }
}

resource "aws_cloudfront_origin_request_policy" "websocket" {
  count = var.has_websocket ? 1 : 0
  name = "${local.canonical_name}-websocket-origin-request-policy"

  cookies_config {
    cookie_behavior = "all"
  }

  query_strings_config {
    query_string_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Sec-WebSocket-Key", "Sec-WebSocket-Version", "Sec-WebSocket-Protocol", "Sec-WebSocket-Accept", "Sec-WebSocket-Extensions"]
    }
  }
}
