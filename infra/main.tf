terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "eu-west-2"  
}


module "vpc" {
 source = "./modules/vpc"
}

module "alb" {
  source = "./modules/alb"
}

module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source = "./modules/ecs"
}


resource "aws_acm_certificate" "acm_cert" {
  domain_name               = "raheemscustomdomain.co.uk"
  subject_alternative_names = ["tm.raheemscustomdomain.co.uk"]
  validation_method         = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_listener" "HTTPS_listner" {
  load_balancer_arn = aws_lb.alb-app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.acm_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_listener_certificate" "listener_cert" {
  listener_arn    = aws_lb_listener.HTTPS_listner.arn
  certificate_arn = aws_acm_certificate.acm_cert.arn
}

data "aws_route53_zone" "route53_zone" {
  name = "raheemscustomdomain.co.uk"
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
  type    = "A"
  name    = "tm.raheemscustomdomain.co.uk"
  alias {
    name                   = aws_lb.alb-app.dns_name
    zone_id                = aws_lb.alb-app.zone_id
    evaluate_target_health = false
  }
}