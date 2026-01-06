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


resource "aws_vpc" "CustomVPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Custom-VPC"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.CustomVPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Public-Subnet1"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id     = aws_vpc.CustomVPC.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "eu-west-2b"


  tags = {
    Name = "Public-Subnet2"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.CustomVPC.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.CustomVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

tags     = {
  Name   = "PublicRT"
}
  
}

resource "aws_route_table_association" "public-route-association" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public-route-association2" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_subnet" "PrivateSubnet1" {
  vpc_id     = aws_vpc.CustomVPC.id
  cidr_block = "10.0.6.0/24"

  tags = {
    Name = "Private-Subnet1"
  }
}

resource "aws_eip" "nat_eip" {
 domain = "vpc"

}
resource "aws_nat_gateway" "Nat_gw" {
  allocation_id = aws_eip.nat_eip.allocation_id
  subnet_id = aws_subnet.PublicSubnet1.id

  depends_on = [aws_internet_gateway.gw]
}


resource "aws_route_table" "Priv_RT" {

  vpc_id = aws_vpc.CustomVPC.id
  route {

    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat_gw.id

  }

}


resource "aws_route_table_association" "private_route_association" {

  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.Priv_RT.id

}

resource "aws_subnet" "PrivateSubnet2" {
  vpc_id     = aws_vpc.CustomVPC.id
  cidr_block = "10.0.7.0/24"

  tags = {
    Name = "Private-Subnet2"
  }
}

resource "aws_route_table_association" "private_route_association2" {

  subnet_id      = aws_subnet.PrivateSubnet2.id
  route_table_id = aws_route_table.Priv_RT.id

}
resource "aws_security_group" "ALB_SG" {
  name        = "ALB_SG"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.CustomVPC.id

  tags = {
    Name = "ALB-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.ALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "custom" {
  security_group_id = aws_security_group.ALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.ALB_SG.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_lb" "alb-app" {
  name               = "alb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_SG.id]
  subnets = [ aws_subnet.PublicSubnet1.id,aws_subnet.PublicSubnet2.id]

  enable_deletion_protection = true

}


resource "aws_lb_target_group" "alb_tg" {
  name        = "alb-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.CustomVPC.id
}
resource "aws_lb_listener" "port80" {
  load_balancer_arn = aws_lb.alb-app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ECSTG.arn
  }
}

resource "aws_ecr_repository" "ecsapp" {
  name                 = "ecsapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
}
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.ecsapp.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire old images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
resource "aws_lb_target_group" "ECSTG"{
  name        = "ECSTG"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.CustomVPC.id
}
resource "aws_ecs_cluster" "ThreatComposer" {
  name = "Threat-Composer"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "ecs_app_logs" {
  name              = "/ecs/ecsapplogs"
  retention_in_days = 7
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "TC-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "ecsapp"
      image     = "789150471589.dkr.ecr.eu-west-2.amazonaws.com/ecsapp"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/ecsapplogs"
          "awslogs-region"        = "eu-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs_task_sg"
  description = "Allow inbound access"
  vpc_id      = aws_vpc.CustomVPC.id

ingress {
    from_port                = 3000
    to_port                  = 3000
    protocol                 = "tcp"
    security_groups          = [aws_security_group.ALB_SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ecs_task_sg"
  }
}

resource "aws_ecs_service" "ECS_Service" {

  depends_on = [
    aws_iam_role.ecs_task_role,
    aws_iam_role.ecs_task_execution_role,
    aws_iam_role_policy_attachment.ecs_task_execution_attach,
    aws_ecs_task_definition.task_definition
  ]

  name            = "ECS_Service"
  cluster         = aws_ecs_cluster.ThreatComposer.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
  launch_type = "FARGATE"

  network_configuration {
  subnets         = [aws_subnet.PrivateSubnet1.id,aws_subnet.PrivateSubnet2.id]
  security_groups = [aws_security_group.ecs_task_sg.id]
  assign_public_ip = false
}


  load_balancer {
    target_group_arn = aws_lb_target_group.ECSTG.arn
    container_name   = "ecsapp"
    container_port   = 3000
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

resource "aws_route53_zone" "route53_zone" {
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
  zone_id         = aws_route53_zone.route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}

resource "aws_route53_record" "Alias" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  type    = "A"
  name    = "tm.raheemscustomdomain.co.uk"
  alias {
    name                   = aws_lb.alb-app.dns_name
    zone_id                = aws_lb.alb-app.zone_id
    evaluate_target_health = false
  }
}