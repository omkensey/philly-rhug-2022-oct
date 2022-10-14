terraform {
  required_providers {
#    ocm = {
#      source = "rh-mobb/ocm"
#      version = "0.1.10"
#    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

/*provider "ocm" {
}

variable "ocm_cluster_id" {
  type = string
}

data "ocm_cloud_providers" "init" {
}

data "ocm_machine_types" "init" {
}
*/

provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "ose_admin" {
  name = "osdCcsAdmin"
}

resource "aws_iam_user_policy_attachment" "ose_admin_access" {
  user       = aws_iam_user.ose_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "ose_admin" {
  user = aws_iam_user.ose_admin.name
}

resource "random_password" "ose_admin_pass" {
  length = 16
}

/*
data "external" "read_env" {
  program = [ "${path.root}/scripts/env.sh" ]
}
*/

/*resource "ocm_cluster" "first_cluster" {
  cloud_provider = "aws"
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_access_key_id = aws_iam_access_key.ose_admin.id
  aws_secret_access_key = aws_iam_access_key.ose_admin.secret
  cloud_region = "us-east-2"
  compute_nodes = 4
  compute_machine_type = "t3a.xlarge"
  ccs_enabled = true
  name = "rhug-oct-22-osd"
  product = "osd"
}*/

/* resource "ocm_identity_provider" "first_cluster_idp" {
  cluster = var.ocm_cluster_id
  name    = "first_cluster-idp"
  htpasswd = {
    username = "ose-admin"
    password = random_password.ose_admin_pass.result
  }
}

resource "ocm_group_membership" "cluster_admin" {
  cluster = var.ocm_cluster_id
  group   = "cluster-admins"
  user    = "cluster-admin"
}*/

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "region-name"
    values = [ var.aws_region ]
  }
}

data "http" "admin_ip_dyn" {
  url = "http://whatismyip.akamai.com/"
}

resource "random_pet" "unique_name" {
}

resource "random_password" "demo_password" {
  length = 16
}

locals {
  admin_ip_result = "${data.http.admin_ip_dyn.body}/32"
  unique_name = coalesce(var.unique_name, random_pet.unique_name.id)
  unique_name_under = replace(local.unique_name, "-", "_")
}

resource "aws_vpc" "main" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = aws_vpc.main.cidr_block
}

resource "aws_security_group" "admin" {
  name = local.unique_name
  vpc_id = aws_vpc.main.id
  ingress {
    description = "Unrestricted admin access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = flatten([var.aws_vpc_cidr, local.admin_ip_result, "65.204.7.5/32"])
  }
  egress {
    description = "Unrestricted egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_instance" "philly_rhug_ansible_controller" {
  associate_public_ip_address = true
  ami           = "ami-092b43193629811af"
  subnet_id     = aws_subnet.public.id
  instance_type = var.aws_instance_type
  key_name = var.aws_ssh_keypair
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_security_group_ids = [ aws_security_group.admin.id ]
}

/*resource "aws_instance" "philly_rhug_app" {

}*/
