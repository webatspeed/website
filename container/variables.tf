variable "cluster_name" {}

variable "enable_insights" {
  type    = bool
  default = false
}

variable "region" {}

variable "private_subnet_ids" {}

variable "mongodb_sg" {}

variable "subscription_sg" {}

variable "frontend_sg" {}

variable "file_system_id" {}

variable "db_user" {}

variable "db_password" {}

variable "lb_target_group_arn" {}

variable "lb_port" {}

variable "port" {}

variable "ses_username" {}

variable "ses_password" {}

variable "bucket" {}

variable "email" {}

variable "file_system_access_id" {}

variable "count_mongodb" {}

variable "count_subscription" {}

variable "count_frontend" {}

variable "registry_frontend_arn" {}

variable "registry_subscription_arn" {}

variable "registry_mongodb_arn" {}

variable "mongo_host" {}

variable "mongo_port" {}
