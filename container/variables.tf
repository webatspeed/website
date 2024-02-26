variable "cluster_name" {}

variable "enable_insights" {
  type    = bool
  default = false
}

variable "region" {}

variable "private_subnet_ids" {}

variable "mongodb_sg" {}

variable "frontend_sg" {}

variable "file_system_id" {}

variable "db_user" {}

variable "db_password" {}

variable "lb_target_group_arn" {}

variable "lb_port" {}
