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


module "vpc" {
 source = "./modules/vpc"
}

module "alb" {
  source = "./modules/alb"
}

module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source = "./modules/ecs"
}

module "acm" {
  source = "./modules/acm"
}