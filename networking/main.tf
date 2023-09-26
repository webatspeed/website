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


data "aws_availability_zones" "available" {}

resource "random_shuffle" "availability_zones" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_subnet" "webatspeed_public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.webatspeed-vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.availability_zones.result[count.index]
  tags = {
    Name = "webatspeed_public_${count.index + 1}"
  }
}

resource "aws_subnet" "webatspeed_private_subnet" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.webatspeed-vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.availability_zones.result[count.index]
  tags = {
    Name = "webatspeed_private_${count.index + 1}"
  }
}
