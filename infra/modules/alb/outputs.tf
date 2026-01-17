output "alb_id" {
  value = aws_lb.alb-app
}

output "alb_sg_id" {
  value = aws_security_group.ALB_SG
}

output "alb_tg" {
  value = aws_lb_target_group.alb_tg
}

output "dns_name1" {
  value = aws_lb.alb-app.dns_name
}

output "alb_zone_id1" {
  value = aws_lb.alb-app.zone_id
}

output "alb_tg_arn" {
  value = aws_lb_target_group.alb_tg.arn
}