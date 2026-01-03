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

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_lb" "alb-app" {
  name               = "alb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_SG.id]
  subnets = [ aws_subnet.PublicSubnet1.id,aws_subnet.PublicSubnet2.id]

  enable_deletion_protection = true

}

resource "aws_ecr_repository" "ecsapp" {
  name                 = "ecsapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
}
resource "aws_ecr_repository_policy" "ecsapp_policy" {
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
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "TC-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

   execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskRole"

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
