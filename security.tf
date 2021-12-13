
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
          sites                       = lookup(var.segments, app.segment).sites  # replace with map[key]
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
 ## On-Prem Sites for Domain EPG ##
 appepgsitelist = flatten([
  for epg_key, epg in local.appepgmap : [
    for site_key, site in epg.sites :
      {
        app_name       = epg.app_name
        segment        = epg.segment
        epg_name       = epg.epg_name
        site_name      = site.name
        vmm_domain     = site.vmm_domain
      }
      if site.type == "aci"
      ]
  ])
  appepgsitemap = {
    for val in local.appepgsitelist:
      lower(format("%s-%s-%s", val["app_name"], val["epg_name"], val["site_name"])) => val
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
# Open Issue re:  None.get()

resource "mso_schema_site_anp_epg_domain" "vmm" {
  for_each = local.appepgsitemap

  schema_id                   = mso_schema.schema.id
  template_name               = mso_schema_template.segments[each.value.segment].name
  site_id                     = data.mso_site.sites[each.value.site_name].id
  anp_name                    = each.value.app_name
  epg_name                    = each.value.epg_name
  domain_type                 = "vmmDomain"
  dn                          = each.value.vmm_domain
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
# NOTE: Doesn't work until VRF configured per Site
# Seems to have issues with VRF name - Error: "Bad Request: None.get"{} - Set VRF in GUI to fix

resource "mso_schema_template_external_epg" "users" {
  for_each = var.users

  schema_id           = mso_schema.schema.id
  template_name       = mso_schema_template.segments[each.value.segment].name
  external_epg_name   = each.value.name
  external_epg_type   = each.value.type # "cloud"
  display_name        = each.value.display_name
  vrf_name            = mso_schema_template_vrf.segments[each.value.segment].name # VRF name sames as Template
  anp_name            = each.value.anp
  // l3out_name          = "unspecified"
  site_id             = [ for site_name in each.value.sites :  data.mso_site.sites[site_name].id ]  ## List?
  selector_name       = each.value.name # use epg_name
  selector_ip         = each.value.ip

  depends_on = [
    mso_schema_site_vrf.vrf
    // mso_schema_site_vrf_region.region
  ]
}

### Filters ###




### Contracts ###
