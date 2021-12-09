### Deploy Trigger ###
resource "mso_schema_template_deploy" "deploy" {
  for_each = var.segments

  schema_id       = mso_schema.schema.id
  template_name   = each.value.name

  depends_on = [mso_schema_site_vrf_region.region, mso_schema_template_bd_subnet.subnet]
}
