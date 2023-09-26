module "compute" {
  source = "./compute"
}

module "networking" {
  source   = "./networking"
  vpc_cidr = local.vpc_cidr
}
