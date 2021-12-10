
### Application Network Profiles ###
resource "mso_schema_template_anp" "anp" {
  for_each = var.applications

  schema_id       = mso_schema.schema.id
  template        = mso_schema_template.segments[each.value.template].name
  name            = each.value.name
  display_name    = each.value.display_name
}

## Need parallelism?? for multiple ANPs

locals {
   appepglist = flatten([
    for app_key, app in var.applications : [
      for epg_key, epg in app.epgs :
        {
          app_name                    = app.name
          template                    = app.template
          epg_name                    = epg.name
          epg_display_name            = epg.display_name
          bd_name                     = epg.bd_name
          useg_enabled                = epg.useg_enabled
          intra_epg                   = epg.intra_epg
          intersite_multicast_source  = epg.intersite_multicast_source
          preferred_group             = epg.preferred_group
        }
        // if site.type != "aci"
    ]
  ])
  appepgmap = {
    for val in local.appepglist:
      lower(format("%s-%s", val["app_name"], val["epg_name"])) => val
  }
}


### Application EPGs ###
resource "mso_schema_template_anp_epg" "epg" {
  for_each = local.appepgmap

  schema_id                   = mso_schema.schema.id
  template_name               = mso_schema_template.segments[each.value.template].name
  anp_name                    = each.value.app_name
  name                        = each.value.epg_name
  bd_name                     = each.value.bd_name
  vrf_name                    = mso_schema_template_vrf.segments[each.value.template].name # VRF name sames as Template
  display_name                = each.value.epg_display_name
  // useg_epg                    = each.value.useg_enabled
  // intra_epg                   = each.value.intra_epg #"unenforced"
  // intersite_multicast_source  = each.value.intersite_multicast_source
  // preferred_group             = each.value.preferred_group
}

### External EPGs ###

### Filters ###

### Contracts ###
