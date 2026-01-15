variable "all_traffic_cidr" {
  type = string
  default = "0.0.0.0/0"
}

variable "app_port" {
  type = string
  description = "port number for app"
  default = "3000"
  
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