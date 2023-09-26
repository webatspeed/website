module "networking" {
  source   = "./networking"
  vpc_cidr = local.vpc_cidr

  max_subnets          = 20
  public_subnet_count  = 2
  public_cidrs         = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_subnet_count = 1
  private_cidrs        = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  security_groups      = local.security_groups
}

module "loadbalancing" {
  source         = "./loadbalancing"
  public_sg      = module.networking.public_sg
  public_subnets = module.networking.public_subnets

  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_interval            = 30
  lb_timeout             = 3
  tg_port                = 8000
  tg_protocol            = "HTTP"
  vpc_id                 = module.networking.vpc_id

  listener_port     = 80
  listener_protocol = "HTTP"
}

module "compute" {
  source = "./compute"

  instance_count = 1
  instance_type  = "t3.small"
  vol_size       = 10

  public_sg      = module.networking.public_sg
  public_subnets = module.networking.public_subnets

  lb_target_group_arn = module.loadbalancing.lb_target_group_arn
  key_name            = "webatspeed-key"
  public_key_path     = var.public_key_path
  tg_port             = 8000
}
