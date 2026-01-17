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