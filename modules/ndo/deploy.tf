locals {
  deploycheck = var.undeploy == false ? var.segments : null
}

locals {
  undeploycheck = var.undeploy == true ? merge(local.cloudsitemap, local.acisitemap) : null
}


// ### Deploy Trigger ###
// resource "mso_schema_template_deploy" "deploy" {
//   // for_each = var.segments
//   for_each = local.deploycheck
//
//   schema_id       = mso_schema.schema.id
//   template_name   = each.value.name
//
//   depends_on = [mso_schema_site_vrf_region.region, mso_schema_template_bd_subnet.subnet]
// }
//
// ### Undeploy Trigger ####
// resource "mso_schema_template_deploy" "undeploy" {
//   // for_each = merge(local.cloudsitemap, local.acisitemap)
//   for_each = local.undeploycheck
//
//   schema_id       = mso_schema.schema.id
//   template_name   = each.value.segment_name
//   site_id         = data.mso_site.sites[each.value.site_name].id
//   undeploy        = true
//
//   depends_on = [mso_schema_site_vrf_region.region, mso_schema_template_bd_subnet.subnet]
// }
