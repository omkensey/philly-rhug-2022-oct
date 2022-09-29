terraform {
  required_providers {
    ocm = {
      source = "rh-mobb/ocm"
      version = "0.1.10"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "ocm" {
}

data "ocm_cloud_providers" "init" {
}

data "ocm_machine_types" "init" {
}

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

resource "ocm_cluster" "first_cluster" {
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
}

resource "ocm_identity_provider" "first_cluster_idp" {
  cluster = ocm_cluster.first_cluster.id
  name    = "first_cluster-idp"
  htpasswd = {
    username = "ose-admin"
    password = random_password.ose_admin_pass.result
  }
}

resource "ocm_group_membership" "cluster_admin" {
  cluster = ocm_cluster.first_cluster.id
  group   = "cluster-admins"
  user    = "ose-admin"
}
