variable "unique_name" {
  type = string
  default = "philly-rhug"
}

variable "aws_ssh_keypair" {
  type = string
  default = "root@instruqt-vm"
}

variable "aws_tags" {
  type = map(string)
  default = {}
}

variable "aws_region" {
  type = string
  default = "us-east-2"
}

variable "aws_vpc_cidr" {
  type = string
  default = "10.14.0.0/16"
}

variable "aws_instance_type" {
  type = string
  default = "m5.large"
}

variable "redhat_username" {
  type = string
}

variable "redhat_password" {
  type = string
  sensitive = true
}

variable "scale" {
  type = number
  default = 1
}
