module "compute" {
  source = "./compute"
}

module "networking" {
  source   = "./networking"
  vpc_cidr = local.vpc_cidr

  max_subnets          = 20
  public_subnet_count  = 1
  public_cidrs         = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_subnet_count = 1
  private_cidrs        = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
}
