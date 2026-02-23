resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  # Origen principal (tu MFE actual, el default)
  origin {
    domain_name              = var.domain_name
    origin_id                = "s3-default"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Orígenes adicionales (uno por cada MFE extra)
  dynamic "origin" {
    for_each = var.extra_origins
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.key
      origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    }
  }

  # Behavior default → MFE principal
  default_cache_behavior {
    target_origin_id       = "s3-default"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  # Behaviors por path → cada MFE extra
  dynamic "ordered_cache_behavior" {
    for_each = var.extra_origins
    content {
      path_pattern           = "/${ordered_cache_behavior.key}/*"
      target_origin_id       = ordered_cache_behavior.key
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]

      forwarded_values {
        query_string = false
        cookies { forward = "none" }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
