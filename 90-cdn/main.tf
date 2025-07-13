resource "aws_cloudfront_distribution" "roboshop" {
  origin {
    domain_name = "cdn.${var.zone_name}"
    custom_origin_config {
      http_port              = 80 // Required to be set but not used
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    origin_id = "cdn.${var.zone_name}" #cdn.devops84.shop
  }
  enabled = true
  aliases = ["cdn.varshin.xyz"]
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "cdn.${var.zone_name}"
    viewer_protocol_policy = "https-only"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cacheDisable.id # :no_entry_symbol: Caching disabled via custom policy
  }
  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/media/*"                 # :dart: Only applies to /media/ paths (e.g., /media/file.jpg)
    allowed_methods  = ["GET", "HEAD", "OPTIONS"] # :white_tick: HTTP methods allowed
    cached_methods   = ["GET", "HEAD", "OPTIONS"] # :card_file_box: These responses will be cached
    target_origin_id = "cdn.${var.zone_name}"     # :link: Connects to defined origin
    viewer_protocol_policy = "https-only"                                    # :closed_lock_with_key: Force HTTPS from viewer
    cache_policy_id        = data.aws_cloudfront_cache_policy.cacheEnable.id # :white_tick: Enable caching
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"              # :white_tick: Allow only specific countries
      locations        = ["US", "CA", "GB", "DE"] # :earth_africa: Users only from US, Canada, UK, Germany
    }
  }
  tags = merge(
    local.common_tags, {
      Name = "${var.project}-${var.environment}"
    }
  )
  viewer_certificate {
    acm_certificate_arn = local.acm_certificate_arn # :closed_lock_with_key: SSL cert from ACM (must be in us-east-1)
    ssl_support_method  = "sni-only"                # :white_tick: Cheaper SSL method for modern browsers
    # cloudfront_default_certificate = true
  }
}
# Creating route 53 for cdn
resource "aws_route53_record" "frontend_alb" {
  zone_id = var.zone_id
  name    = "cdn.${var.zone_name}" #cdn.devops84.shop
  type    = "A"                    # :repeat: Alias record type (IPv4)
  alias {
    name                   = aws_cloudfront_distribution.roboshop.domain_name    # :satellite_antenna: Points to CloudFront
    zone_id                = aws_cloudfront_distribution.roboshop.hosted_zone_id # :id: Hosted zone of CloudFront
    evaluate_target_health = true                                                # :white_tick: DNS failover if target is unhealthy
  }
}