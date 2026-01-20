variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "publicsubnet1" {
  type = string
}

variable "publicsubnet2" {
  type = string
  
}

variable "albtg_arn" {
  type = string
}

variable "app_name" {
  type = string
  default = "ecsapp"
} 


variable "app_port" {
  type = string
  default = "3000"
}


variable "all_traffic" {
  type = string
  default = "0.0.0.0/0"
}

variable "cpu" {
  type = string
  description = "cpu for task definition"
  default = "256"
}
  
variable "memory" {
  type = string
  description = "memory for task definition"
  default = "512"
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "container_name1" {
  type = string
  default = "ecsapp"
}

variable "app_image1" {
  type = string
  default = "789150471589.dkr.ecr.eu-west-2.amazonaws.com/ecsapp:latest"
}