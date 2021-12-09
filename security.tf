
### Application Network Profiles ###
resource "mso_schema_template_anp" "anp" {
  for_each = var.applications

  schema_id       = mso_schema.schema.id
  template        = mso_schema_template.segments[each.value.template].name
  name            = each.value.name
  display_name    = each.value.display_name
}

## Need parallelism?? for multiple ANPs





### Application EPGs ###
// resource "mso_schema_template_anp_epg" "anp_epg" {
//   schema_id = "5c4d5bb72700000401f80948"
//   template_name = "Template1"
//   anp_name = "ANP"
//   name = "mso_epg1"
//   bd_name = "BD1"
//   vrf_name = "DEVNET-VRF"
//   display_name = "mso_epg1"
//   useg_epg = true
//   intra_epg = "unenforced"
//   intersite_multicast_source = false
//   preferred_group = false
// }

### External EPGs ###

### Filters ###

### Contracts ###
