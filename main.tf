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

resource "ocm_cluster" "first_cluster" {
  cloud_provider = "aws"
  # aws_account = 
  # aws_access_key_id = 
  # aws_secret_access_key = 
  cloud_region = "us-east-1"
  compute_nodes = 4
  compute_machine_type = "t3a.xlarge"
  ccs_enabled = true
  name = "rhug-oct-22-osd"
  product = "osd"
}
