variable "cluster_name" {}

variable "enable_insights" {
  type    = bool
  default = false
}

variable "region" {}

variable "private_subnet_ids" {}

variable "mongodb_sg" {}

variable "file_system_id" {}

variable "db_user" {}

variable "db_password" {}
