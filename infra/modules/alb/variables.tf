variable "all_traffic_cidr" {
  type = string
  default = "0.0.0.0/0"
}

variable "app_port" {
  type = number
  description = "port number for app"
  default = 3000
  
}

variable "vpc_id" {
  type = string
  description = "ID of VPC"
  
}

variable "vpc_subnet1_id" {
  type = string
  description = "ID of 1st Subnet"

}

variable "vpc_subnet2_id" {
    type = string
    description = "ID for 2nd Subnet"
  
}

variable "certificate_arn" {
     type = string
     description = "arn for the certificate"

}

variable "ssl_policy" {
  type = string
  default = "ELBSecurityPolicy-2016-08"
}

variable "health_path" {
  type = string
  default = "/health"
}

variable "health_matcher" {
  type = number
  default = 200
}

variable "health_interval" {
  type = number
  default = 50
}

variable "health_timeout" {
  type = number
  default = 5
}

variable "healthy_threshold" {
  type = number
  default = 2
}

variable "unhealthy_threshold" {
  type = number
  default = 2
}