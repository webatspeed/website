output "public_sg" {
  value = aws_security_group.webatspeed_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.webatspeed_public_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.webatspeed-vpc.id
}
