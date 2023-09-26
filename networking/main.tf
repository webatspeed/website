resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "webatspeed-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "webatspeed_vpc_${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}
