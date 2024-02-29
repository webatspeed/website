resource "aws_efs_file_system" "webatspeed_efs" {
}

resource "aws_efs_backup_policy" "webatspeed_efs_bak" {
  file_system_id = aws_efs_file_system.webatspeed_efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "webatspeed_efs_mount_target" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.webatspeed_efs.id
  subnet_id       = element(var.private_subnet_ids, count.index)
  security_groups = var.efs_sg
}

resource "aws_efs_access_point" "webatspeed_efs_access" {
  file_system_id = aws_efs_file_system.webatspeed_efs.id

  root_directory {
    path = "/mongodb"

    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0777"
    }
  }
}
