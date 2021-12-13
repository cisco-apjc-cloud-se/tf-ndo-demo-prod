// locals {
//   deploycheck = var.undeploy == false ? var.segments : {}
//   // deploycheck =  var.undeploy == false ? flatten(var.segments) : []
// }
//
// locals {
//   // undeploycheck = var.undeploy == true ? merge(local.cloudsitemap, local.acisitemap) : null
//   undeploycheck =  var.undeploy == true ? flatten(merge(local.cloudsitemap, local.acisitemap)) : []
// }


locals {
  mergedsites =  merge(local.cloudsitemap, local.acisitemap)
}

// locals {
//   testseg =  merge(var.segments, {})
// }



### Deploy Trigger ###
resource "mso_schema_template_deploy" "deploy" {
  // for_each = var.segments
  for_each = local.mergedsites

  schema_id       = mso_schema.schema.id
  template_name   = each.value.segment_name
  site_id         = var.undeploy == true ? data.mso_site.sites[each.value.site_name].id : "unspecified"
  undeploy        = var.undeploy

  depends_on = [mso_schema_site_vrf_region.region, mso_schema_template_bd_subnet.subnet]
}

// ### Undeploy Trigger ####
// resource "mso_schema_template_deploy" "undeploy" {
//   // for_each = toset( var.undeploy == true ? flatten(merge(local.cloudsitemap, local.acisitemap)) : [] )
//   for_each = var.undeploy == true ? local.mergedsites : {}
//
//   schema_id       = mso_schema.schema.id
//   template_name   = each.value.segment_name
//   site_id         = data.mso_site.sites[each.value.site_name].id
//   undeploy        = true
//
//   depends_on = [mso_schema_site_vrf_region.region, mso_schema_template_bd_subnet.subnet]
// }
