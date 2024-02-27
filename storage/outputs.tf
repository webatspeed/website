output "file_system_id" {
  value = aws_efs_file_system.webatspeed_efs.id
}

output "file_system_access_id" {
  value = aws_efs_access_point.webatspeed_efs_access.id
}
