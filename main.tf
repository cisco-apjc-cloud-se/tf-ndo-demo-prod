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
    mso = {
      source = "CiscoDevNet/mso"
      # version = "~> 0.1.5"
    }
    aws = {
      source = "hashicorp/aws"
      # version = "3.25.0"
    }
    // azurerm = {
    //   source = "hashicorp/azurerm"
    //   # version = "=2.46.0"
    // }
    // azuread = {
    //   source = "hashicorp/azuread"
    //   # version = "1.5.1"
    // }
  }
}

# Note: TFE_PARALLELISM is not supported by Terraform Cloud Agents, but Terraform allows you to specify flags as environment variables directly via TF_CLI_ARGS.
# Use TF_CLI_ARGS_pan = -parallelism=<N>, TF_CLI_ARGS_apply = -parallelism=<N>  instead.

provider "mso" {
  username = data.vault_generic_secret.cpoc-ndo.data["username"]
  password = data.vault_generic_secret.cpoc-ndo.data["password"]
  # url      = "https://aws-syd-ase-n1.mel.ciscolabs.com/mso/"
  url      = "https://100.64.62.122/mso"
  insecure = true
  platform = "nd"
}

## Multi-Cloud Networking Module (Cisco NDO/Cloud ACI) ##
module "ndo" {
  source = "./modules/ndo"

  ## General ##
  // username      = data.vault_generic_secret.cpoc-ndo.data["username"]
  // password      = data.vault_generic_secret.cpoc-ndo.data["password"]
  // url           = "https://100.64.62.122/mso"
  undeploy  = false # Set true to undeploy before destroying

  ## Network Policy Inputs ##
  tenant                = var.tenant
  schema_name           = var.schema_name
  shared_template_name  = var.shared_template_name
  sites                 = var.sites
  segments              = var.segments

  ## Security Policy Inputs ##
  users                 = var.users
  applications          = var.applications
  contracts             = var.contracts
  filters               = var.filters

}

### Setup AWS Provider ###

provider "aws" {
  region     = "ap-southeast-2"
  access_key = data.vault_generic_secret.aws-prod.data["access"]
  secret_key = data.vault_generic_secret.aws-prod.data["secret"]
}

// ## Build Test EC2 Instance(s) ##
// module "aws" {
//   source = "./modules/aws"
//
//   tenant          = var.tenant
//   aws_apps        = var.aws_apps
//   instance_type   = "t3a.micro"
//   public_key      = var.public_key
//
//   depends_on = [
//     module.ndo
//   ]
// }

### Setup Azure Provider(s) ###

// provider "azurerm" {
//   features {}
//   subscription_id = data.vault_generic_secret.azure.data["subscription_id"]
//   tenant_id = data.vault_generic_secret.azure.data["tenant_id"]
//   client_id = data.vault_generic_secret.azure.data["client_id"]
//   client_secret = data.vault_generic_secret.azure.data["client_secret"]
// }
//
// provider "azuread" {
//   # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider to be used
//   # version = "=1.1.0"
//   tenant_id = data.vault_generic_secret.azure.data["tenant_id"]
//   client_id = data.vault_generic_secret.azure.data["client_id"]
//   client_secret = data.vault_generic_secret.azure.data["client_secret"]
// }

// module "azure" {
//   source = "./modules/azure"
//
//   tenant          = var.tenant
//   azure_apps      = var.azure_apps
//   instance_type   = "Standard_B1s"
//   public_key      = var.public_key
//
//   depends_on = [
//     module.ndo
//   ]
// }
