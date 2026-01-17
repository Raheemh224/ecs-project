resource "aws_acm_certificate" "acm_cert" {
  domain_name               = "raheemscustomdomain.co.uk"
  subject_alternative_names = ["tm.raheemscustomdomain.co.uk"]
  validation_method         = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "route53_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}

resource "aws_route53_record" "Alias" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  type    = var.record_type
  name    = var.record_name
  alias {
    name                   = var.dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}