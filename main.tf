data "aws_region" "current" {}

module "network" {
  source = "./modules/network"
}

module "iam" {
  source = "./modules/iam"
}

module "logs" {
  source = "./modules/logs"
}

module "ecs" {
  source = "./modules/ecs"

  subnet_id          = module.network.subnet_ids[0]
  security_group     = module.network.sg_id
  execution_role     = module.iam.execution_role_arn
  log_group_name     = module.logs.log_group_name
  region             = var.region
  target_group_arn   = module.alb.target_group_arn
  listener_dependency = module.alb.listener_arn
}


module "alb" {
  source = "./modules/alb"

  subnet_ids = module.network.subnet_ids
  vpc_id     = module.network.vpc_id
}



module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
}

module "cdn" {
  source       = "./modules/cloudfront"
  project_name = var.project_name
  bucket_id    = module.s3.bucket_id
  bucket_arn   = module.s3.bucket_arn
  domain_name  = module.s3.bucket_domain_name
}
