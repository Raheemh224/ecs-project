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



resource "aws_security_group" "ecstask_sg" {
  name        = "ecstask-sg"
  description = "container port traffic"
  vpc_id      = aws_vpc.ecsapp_vpc.id
  
  tags = {
    Name = "ecstask-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecssg_ingress" {
  security_group_id = aws_security_group.ecstask_sg.id
  referenced_security_group_id = aws_security_group.ALB_SG.id
  from_port   = 3000
  ip_protocol = "tcp"
  to_port     = 3000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.ecstask_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
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
  subnets         = [aws_subnet.PublicSubnet1.id,aws_subnet.PublicSubnet2.id]
  security_groups = [aws_security_group.ecstask_sg.id]
  assign_public_ip = false
}


  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = "ecsapp"
    container_port   = 3000
  }

}
