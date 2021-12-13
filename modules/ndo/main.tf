terraform {
  // experiments = [module_variable_optional_attrs]
  experiments = [module_variable_optional_attrs]
  // backend "remote" {
  //   hostname = "app.terraform.io"
  //   organization = "mel-ciscolabs-com"
  //   workspaces {
  //     name = "tf-ndo-demo-prod"
  //   }
  // }
  required_providers {
    vault = {
      source = "hashicorp/vault"
      # version = "2.18.0"
    }
    mso = {
      source = "CiscoDevNet/mso"
      # version = "~> 0.1.5"
    }
  }
}

# Note: TFE_PARALLELISM is not supported by Terraform Cloud Agents, but Terraform allows you to specify flags as environment variables directly via TF_CLI_ARGS.
# Use TF_CLI_ARGS_pan = -parallelism=<N>, TF_CLI_ARGS_apply = -parallelism=<N>  instead.

provider "mso" {
  // username = data.vault_generic_secret.cpoc-ndo.data["username"]
  username  = var.username
  // password = data.vault_generic_secret.cpoc-ndo.data["password"]
  password  = var.password
  # url      = "https://aws-syd-ase-n1.mel.ciscolabs.com/mso/"
  // url      = "https://100.64.62.122/mso"
  url       = var.url
  insecure  = true
  platform  = "nd"
}

### Shared Data Sources ###
data "mso_tenant" "tenant" {
  name = var.tenant
  display_name = var.tenant # required
}

data "mso_site" "sites" {
  for_each = toset(var.sites)

  name = each.value  # Existing sites defined in NDO happens to be uppercase
}

// data "mso_site" "AWS-SYD" {
//   name  = "AWS-SYD"
// }
//
// data "mso_site" "AZURE-MEL" {
//   name  = "AZURE-MEL"
// }
//
// data "mso_site" "CPOC-SYD" {
//   name  = "CPOC-SYD-DMZ"
// }

### Create Demo Schema & 1st Template ###
resource "mso_schema" "schema" {
  name          = var.schema_name
  template_name = var.shared_template_name
  tenant_id     = data.mso_tenant.tenant.id
}
