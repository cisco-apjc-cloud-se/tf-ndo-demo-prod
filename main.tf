terraform {
  experiments = [module_variable_optional_attrs]
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "mel-ciscolabs-com"
    workspaces {
      name = "tf-ndo-demo-prod"
    }
  }
  required_providers {
    vault = {
      source = "hashicorp/vault"
      # version = "2.18.0"
    }
    // mso = {
    //   source = "CiscoDevNet/mso"
    //   # version = "~> 0.1.5"
    // }
  }
}

# Note: TFE_PARALLELISM is not supported by Terraform Cloud Agents, but Terraform allows you to specify flags as environment variables directly via TF_CLI_ARGS.
# Use TF_CLI_ARGS_pan = -parallelism=<N>, TF_CLI_ARGS_apply = -parallelism=<N>  instead.

// provider "mso" {
//   username = data.vault_generic_secret.cpoc-ndo.data["username"]
//   password = data.vault_generic_secret.cpoc-ndo.data["password"]
//   # url      = "https://aws-syd-ase-n1.mel.ciscolabs.com/mso/"
//   url      = "https://100.64.62.122/mso"
//   insecure = true
//   platform = "nd"
// }

## Common Setup - Schema, Template, VRFs etc
module "ndo" {
  source = "./modules/ndo"
  ## General ##
  username      = data.vault_generic_secret.cpoc-ndo.data["username"]
  password      = data.vault_generic_secret.cpoc-ndo.data["password"]
  url           = "https://100.64.62.122/mso"
  undeploy      = false

  ## Network Policy Inputs ##
  tenant                = var.tenant
  schema_name           = var.schema_name
  shared_template_name  = var.shared_template_name
  sites                 = var.sites
  segments              = var.segments

  ## Security Policy Inputs ##
  users = var.users
  applications = var.applications
  contracts = var.contracts
  filters = var.filters

}
