
### Application Network Profiles ###
resource "mso_schema_template_anp" "anp" {
  for_each = var.applications

  schema_id       = mso_schema.schema.id
  template        = mso_schema_template.segments[each.value.segment].name
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
          segment                     = app.segment
          epg_name                    = epg.name
          epg_display_name            = epg.display_name
          bd_name                     = epg.bd_name
          // useg_enabled                = epg.useg_enabled
          // intra_epg                   = epg.intra_epg
          // intersite_multicast_source  = epg.intersite_multicast_source
          // preferred_group             = epg.preferred_group
          selectors                   = epg.selectors
          test                        = lookup(var.segments, app.segment)
        }
        // if site.type != "aci"
    ]
  ])
  appepgmap = {
    for val in local.appepglist:
      lower(format("%s-%s", val["app_name"], val["epg_name"])) => val
  }

  appepgselectorlist = flatten([
   for epg_key, epg in local.appepgmap : [
     for sel_key, selector in epg.selectors :
       {
         app_name       = epg.app_name
         segment        = epg.segment
         epg_name       = epg.epg_name
         selector_name  = selector.name
         key            = selector.key
         operator       = selector.operator
         value          = selector.value
       }
       // if site.type != "aci"
   ]
 ])
 appepgselectormap = {
   for val in local.appepgselectorlist:
     lower(format("%s-%s-%s", val["app_name"], val["epg_name"], val["selector_name"])) => val
 }
}

output "appepgmap" {
  value = local.appepgmap
}


### Application EPGs ###
resource "mso_schema_template_anp_epg" "epg" {
  for_each = local.appepgmap

  schema_id                   = mso_schema.schema.id
  template_name               = mso_schema_template.segments[each.value.segment].name
  anp_name                    = each.value.app_name
  name                        = each.value.epg_name
  bd_name                     = each.value.bd_name  # "unspecified"
  vrf_name                    = mso_schema_template_vrf.segments[each.value.segment].name # VRF name sames as Template
  display_name                = each.value.epg_display_name
  // useg_epg                    = each.value.useg_enabled
  // intra_epg                   = each.value.intra_epg #"unenforced"
  // intersite_multicast_source  = each.value.intersite_multicast_source
  // preferred_group             = each.value.preferred_group
}

### Application EPG Selectors - Cloud ###
resource "mso_schema_template_anp_epg_selector" "selector" {
  for_each = local.appepgselectormap

  schema_id                   = mso_schema.schema.id
  template_name               = mso_schema_template.segments[each.value.segment].name # VRF name sames as Template
  anp_name                    = each.value.app_name
  epg_name                    = each.value.epg_name
  name                        = each.value.selector_name
  expressions {
    key         = each.value.key
    operator    = each.value.operator
    value       = each.value.value
  }
}

### Application EPG Selectors - On-Premise Domain ###
resource "mso_schema_site_anp_epg_domain" "vmm" {
  # Flatten with on-prem type sites?
  for_each = local.appepgmap

  schema_id                   = mso_schema.schema.id
  template_name               = mso_schema_template.segments[each.value.segment].name
  site_id                     = data.mso_site.sites["CPOC-SYD-DMZ"].id # Initally Hard Coded
  anp_name                    = each.value.app_name
  epg_name                    = each.value.epg_name
  domain_type                 = "vmmDomain"
  dn                          = var.aci_vmm_domain
  deploy_immediacy            = "lazy" # mandatory?
  resolution_immediacy        = "lazy" # mandatory
  // vlan_encap_mode = "static"
  // allow_micro_segmentation = true
  // switching_mode = "native"
  // switch_type = "default"
  // micro_seg_vlan_type = "vlan"
  // micro_seg_vlan = 46
  // port_encap_vlan_type = "vlan"
  // port_encap_vlan = 45
  // enhanced_lag_policy_name = "name"
  // enhanced_lag_policy_dn = "dn"

}

### External EPGs ###

### Filters ###

### Contracts ###
