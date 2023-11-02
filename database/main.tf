resource "aws_db_instance" "webatspeed_db" {
  allocated_storage      = var.db_storage
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  identifier             = var.db_identifier

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  skip_final_snapshot       = var.skip_db_snapshot
  final_snapshot_identifier = "${var.db_identifier}-snapshot"

  tags = {
    Name = "webatspeed-db"
  }
}
