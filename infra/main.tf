module "vpc" {
 source = "./modules/vpc"
}

module "alb" {
  source = "./modules/alb"
 vpc_id = module.vpc.vpc_id
 vpc_subnet1_id = module.vpc.public_subnet1_id
 vpc_subnet2_id = module.vpc.public_subnet2_id
 certificate_arn = module.acm.certificate_arn

}

module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source = "./modules/ecs"
  albtg_arn = module.alb.alb_tg_arn
  publicsubnet1 = module.vpc.public_subnet1_id
  publicsubnet2 = module.vpc.public_subnet2_id
  alb_sg_id = module.alb.alb_sg_id
  vpc_id = module.vpc.vpc_id
  task_role_arn = module.ecs.task_role_arn
  execution_role_arn = module.ecs.execution_role_arn
}

module "acm" {
  source = "./modules/acm"
  zone_id = module.acm.zone_id
  dns_name = module.alb.dns_name1
  alb_zone_id = module.alb.alb_zone_id1
}