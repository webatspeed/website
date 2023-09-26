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


resource "aws_default_route_table" "webatspeed_private_rt" {
  default_route_table_id = aws_vpc.webatspeed-vpc.default_route_table_id

  tags = {
    Name = "webatspeed_private"
  }
}

resource "aws_route_table" "webatspeed_public_rt" {
  vpc_id = aws_vpc.webatspeed-vpc.id

  tags = {
    Name = "webatspeed_public"
  }
}

resource "aws_route_table_association" "webatspeed_public_assoc" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.webatspeed_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.webatspeed_public_rt.id
}

