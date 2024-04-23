variable "aws_region" {
  default = "eu-central-1"
}

variable "access_ip" {
  type = string
}

variable "db_user" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "email" {
  type = string
}

variable "docker_user" {
  type = string
}

variable "docker_pass" {
  type = string
}
