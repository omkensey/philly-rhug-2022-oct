terraform {
  required_providers {
    ocm = {
      source = "rh-mobb/ocm"
      version = "0.1.10"
    }
  }
}

provider "ocm" {
}

data "ocm_cloud_providers" "init" {
}

data "ocm_machine_types" "init" {
}

data "external" "read_env" {
  program = [ "${path.root}/scripts/env.sh" ]
}

resource "ocm_cluster" "first_cluster" {
  cloud_provider = "aws"
#  aws_account_id = data.external.read_env.result["AWS_ACCOUNT_ID"]
#  aws_access_key_id = data.external.read_env.result["AWS_ACCESS_KEY_ID"]
#  aws_secret_access_key = data.external.read_env.result["AWS_SECRET_ACCESS_KEY"]
  cloud_region = "us-east-1"
#  compute_nodes = 4
#  compute_machine_type = "t3a.xlarge"
#  ccs_enabled = false
  name = "rhug-oct-22-osd"
  product = "osd"
}
