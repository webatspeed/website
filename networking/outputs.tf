output "public_sg" {
  value = aws_security_group.webatspeed_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.webatspeed_public_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.webatspeed-vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.webatspeed_rds_subnet_group.*.name
}

output "db_security_group" {
  value = [aws_security_group.webatspeed_sg["rds"].id]
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
