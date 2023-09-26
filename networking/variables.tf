variable "vpc_cidr" {
  type = string
}

variable "max_subnets" {
  type = number
}

variable "public_cidrs" {
  type = list(string)
}

variable "private_cidrs" {
  type = list(string)
}

variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "security_groups" {}

variable "create_db_subnet_group" {
  type = bool
}
