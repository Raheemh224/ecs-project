variable "dns_name" {
  type = string
  description = "DNS of ALB"
}

variable "domain_name" {
  type = string
  description = "name of my domain"
  default = "raheemscustomdomain.co.uk"
}

variable "alb_zone_id" {
  type = string
  description = "zone of the alb"
  
}

variable "zone_id" {
  type = string
  description = "id of hosted zone"
}

variable "record_name" {
    type = string
    default = "tm.raheemscustomdomain.co.uk"
  
}

variable "record_type" {
    type = string
    default = "A"
  
}