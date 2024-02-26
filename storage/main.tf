resource "aws_efs_file_system" "webatspeed_efs" {
}

resource "aws_efs_mount_target" "webatspeed_efs_mount_target" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.webatspeed_efs.id
  subnet_id       = element(var.private_subnet_ids, count.index)
  security_groups = var.efs_sg
}
