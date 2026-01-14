variable "vpc_cidr" {
  type = string
  description = "cidr of the vpc"
  default = "10.0.0.0/16"
}

variable "public_subnet1_cidr" {
  type = string
  description = "cidr of 1st public subnet"
  default = "10.0.4.0/24"
}

variable "public_subnet2_cidr" {
  type = string
  description = "cidr of the 2nd public subnet"
  default = "10.0.5.0/24"
}

variable "availability_zone1" {
  type = string
  description = "AZ for subnet1"
  default = "eu-west-2a"
}

variable "availability_zone2" {
   type = string
   description = "AZ for subnet2"
   default = "eu-west-2b"
  
}

variable "route_table" {
  type = string
  description = "CIDR of route table"
  default = "0.0.0.0/0"
}