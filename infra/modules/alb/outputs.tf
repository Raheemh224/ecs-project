output "alb_id" {
  value = aws_lb.alb-app
}

output "alb_sg_id" {
  value = aws_security_group.ALB_SG
}

output "alb_tg" {
  value = aws_lb_target_group.alb_tg
}