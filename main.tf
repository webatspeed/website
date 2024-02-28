module "networking" {
  source = "./networking"

  vpc_cidr               = local.vpc_cidr
  max_subnets            = 20
  public_subnet_count    = 2
  public_cidrs           = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_subnet_count   = 2
  private_cidrs          = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  security_groups        = local.security_groups
  create_db_subnet_group = true
}

module "loadbalancing" {
  source = "./loadbalancing"

  public_sg      = module.networking.public_sg
  public_subnets = module.networking.public_subnets

  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_interval            = 30
  lb_timeout             = 3
  tg_port                = 8000
  tg_protocol            = "HTTP"
  vpc_id                 = module.networking.vpc_id

  listener_ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn     = module.routing.certificate_arn
}

module "routing" {
  source = "./routing"

  dns_name   = module.loadbalancing.lb_endpoint
  zone_id    = module.loadbalancing.lb_zone_id
  aws_region = var.aws_region
}

module "mailing" {
  source = "./mailing"

  email           = var.email
  email_templates = local.email_templates
  attachment_dir  = "attachments"
}

module "storage" {
  source = "./storage"

  efs_sg             = module.networking.efs_security_group
  private_subnet_ids = module.networking.private_subnet_ids
}

module "discovery" {
  source = "./discovery"

  vpc_id = module.networking.vpc_id
}

module "container" {
  source = "./container"

  enable_insights           = true
  cluster_name              = "webatspeed-cluster"
  region                    = var.aws_region
  private_subnet_ids        = module.networking.private_subnet_ids
  mongodb_sg                = module.networking.mongo_security_group
  frontend_sg               = module.networking.public_sg
  file_system_id            = module.storage.file_system_id
  db_user                   = var.db_user
  db_password               = var.db_password
  lb_target_group_arn       = module.loadbalancing.lb_target_group_arn
  lb_port                   = 3000
  bucket                    = module.mailing.bucket_name
  email                     = var.email
  port                      = 8080
  ses_username              = module.mailing.smtp_username
  ses_password              = module.mailing.smtp_password
  subscription_sg           = module.networking.subscription_security_group
  file_system_access_id     = module.storage.file_system_access_id
  registry_frontend_arn     = module.discovery.registry_frontend_arn
  registry_mongodb_arn      = module.discovery.registry_mongodb_arn
  registry_subscription_arn = module.discovery.registry_subscription_arn
  mongo_host                = module.discovery.mongo_host

  count_frontend     = 1
  count_mongodb      = 1
  count_subscription = 1
}
