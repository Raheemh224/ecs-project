resource "aws_lb" "alb-app" {
  name               = "alb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_SG.id]
  subnets = [ var.vpc_subnet1_id,var.vpc_subnet2_id]

  enable_deletion_protection = true

}


resource "aws_security_group" "ALB_SG" {
  name        = "ALB_SG"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ALB-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.ALB_SG.id
  cidr_ipv4         = var.all_traffic_cidr
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ALB_SG.id
  cidr_ipv4         = var.all_traffic_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.ALB_SG.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.all_traffic_cidr
}
resource "aws_lb_target_group" "alb_tg" {
  name        = "alb-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.health_path
    matcher             = var.health_matcher
    interval            = var.health_interval
    timeout             = var.health_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb-app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "HTTPS_listner" {
  load_balancer_arn = aws_lb.alb-app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_listener_certificate" "listener_cert" {
  listener_arn    = aws_lb_listener.HTTPS_listner.arn
  certificate_arn = var.certificate_arn
}
