### Create Template for each Network Segment ###

resource "mso_schema_template" "segments" {
  for_each = var.segments

  schema_id       = mso_schema.ndo-demo-prod.id
  name            = each.value.name
  display_name    = each.value.display_name
  tenant_id       = data.mso_tenant.Production.id
}
