output "certificate_arn" {
  value = aws_acm_certificate.acm_cert.arn
}

output "zone_id" {
  value = data.aws_route53_zone.route53_zone.zone_id
  
}