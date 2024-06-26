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

resource "aws_eip" "webatspeed_nat_eip" {
  count      = var.public_subnet_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.webatspeed_internet_gateway]
}

resource "aws_nat_gateway" "webatspeed_nat_gateway" {
  count         = var.use_nat_gateway ? var.public_subnet_count : 0
  allocation_id = element(aws_eip.webatspeed_nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.webatspeed_public_subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.webatspeed_internet_gateway]
}

resource "aws_route_table" "webatspeed_private_rt" {
  count  = var.public_subnet_count
  vpc_id = aws_vpc.webatspeed-vpc.id

  dynamic "route" {
    for_each = aws_nat_gateway.webatspeed_nat_gateway
    content {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.webatspeed_nat_gateway[route.key].id
    }
  }

  tags = {
    Name = "private-${count.index}"
  }
}

resource "aws_route_table_association" "webatspeed_private_assoc" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.webatspeed_private_subnet[count.index].id
  route_table_id = aws_route_table.webatspeed_private_rt[count.index].id
}

//noinspection HILUnresolvedReference
resource "aws_security_group" "webatspeed_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.webatspeed-vpc.id

  //noinspection HILUnresolvedReference
  dynamic "ingress" {
    for_each = each.value.ingress
    //noinspection HILUnresolvedReference
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_internet_gateway" "webatspeed_internet_gateway" {
  vpc_id = aws_vpc.webatspeed-vpc.id

  tags = {
    Name = "webatspeed_igw"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.webatspeed_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.webatspeed_internet_gateway.id
}

