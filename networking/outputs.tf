output "public_sg" {
  value = aws_security_group.webatspeed_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.webatspeed_public_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.webatspeed-vpc.id
}

output "fe_security_group" {
  value = [aws_security_group.webatspeed_sg["frontend"].id]
}

output "mongo_security_group" {
  value = [aws_security_group.webatspeed_sg["mongodb"].id]
}

output "efs_security_group" {
  value = [aws_security_group.webatspeed_sg["efs"].id]
}

output "private_subnet_ids" {
  value = aws_subnet.webatspeed_private_subnet.*.id
}
