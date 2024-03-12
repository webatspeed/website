variable "public_sg" {}
variable "public_subnets" {}
variable "tg_port" {
  type = number
}
variable "tg_protocol" {
  type = string
}
variable "vpc_id" {}
variable "lb_healthy_threshold" {
  type = number
}
variable "lb_unhealthy_threshold" {
  type = number
}
variable "lb_timeout" {
  type = number
}
variable "lb_interval" {
  type = number
}
variable "listener_ssl_policy" {}
variable "certificate_arn" {}
variable "use" {}
