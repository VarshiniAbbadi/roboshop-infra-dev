resource "aws_acm_certificate" "varshin" {
  domain_name       = "${var.environment}.${var.zone_name}"
  validation_method = "DNS"

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "varshin" {
  for_each = {
    for dvo in aws_acm_certificate.varshin.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "varshin" {
  certificate_arn         = aws_acm_certificate.varshin.arn
  validation_record_fqdns = [for record in aws_route53_record.varshin : record.fqdn]
}