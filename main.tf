terraform {
  required_providers {
    gandi = {
      version = "2.3.0"
      source  = "go-gandi/gandi"
    }
  }
}

provider "gandi" {}

locals {
  ignore_domains = [
    "id-ed25519.pub",
  ]
}

data "terraform_remote_state" "aws" {
  backend = "http"
  config = {
    address = "https://raw.githubusercontent.com/akerl/aws-account/main/terraform.tfstate"
  }
}

resource "gandi_nameservers" "ns" {
  for_each    = toset([for i, x in data.terraform_remote_state.aws.outputs.domains : x if !contains(local.ignore_domains, x)])
  domain      = each.key
  nameservers = data.terraform_remote_state.aws.outputs.nameservers
}
