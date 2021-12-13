### Undeploy Trigger ####
resource "mso_schema_template_deploy" "undeploy" {
  for_each = merge(local.cloudsitemap, local.acisitemap)

  schema_id       = mso_schema.schema.id
  template_name   = each.value.segment_name
  site_id         = data.mso_site.sites[each.value.site_name].id
  undeploy        = true

  depends_on = [mso_schema_site_vrf_region.region, mso_schema_template_bd_subnet.subnet]
}
