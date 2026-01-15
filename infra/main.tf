module "vpc" {
 source = "./modules/vpc"
}

module "alb" {
  source = "./modules/alb"
 vpc_id = module.vpc.vpc_id
 vpc_subnet1_id = module.vpc.public_subnet1_id
 vpc_subnet2_id = module.vpc.public_subnet2_id
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