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