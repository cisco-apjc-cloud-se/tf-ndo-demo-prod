### Create New Template Network Segments ###

resource "mso_schema_template_vrf" "segments" {
  for_each = var.segments

  schema_id       = mso_schema.schema.id
  template        = mso_schema_template.segments[each.key].name
  name            = lower(each.value.name)           # Assumes new VRF name to match template name
  display_name    = each.value.display_name   # Assumes new VRF name to match template name
  # layer3_multicast= false
  # vzany           = false
}


## Local Flattened Dictionary for Sites ##
locals {
   sitelist = flatten([
    for seg_key, segment in var.segments : [
      for site_key, site in segment.sites  :
        {
          segment_name  = segment.name
          site_name     = site.name
          site_type     = site.type
          regions       = site.regions
        }
    ]
  ])
  sitemap = {
    for val in local.sitelist:
      // format("%s-%s", val["host_key"], val["network_name"]) => val
      lower(format("%s-%s", val["segment_name"], val["site_name"])) => val
  }

  regionlist = flatten([
    for site_key, site in local.sitemap : [
      for region_key, region in site.regions :
      {
        segment_name      = site.segment_name
        site_name         = site.site_name
        site_type         = site.type
        region_name       = region.name
        region_hub        = region.hub_name
        region_cidrs      = region.cidrs
        // region_subnets  = region.subnets
      }
    ]
  ])
  regionmap = {
    for val in local.regionlist:
      lower(format("%s-%s-%s", val["segment_name"], val["site_name"], val["region_name"])) => val
  }

  acisitelist = flatten([
   for seg_key, segment in var.segments : [
     for site_key, site in segment.sites  :
       site.type == "aci" ? {
         segment_name  = segment.name
         site_name     = site.name
         site          = site
       }: null
   ]
  ])
  acisitemap = {
    for val in local.acisitelist:
     // format("%s-%s", val["host_key"], val["network_name"]) => val
      lower(format("%s-%s", val["segment_name"], val["site_name"])) => val
  }

  acibdlist = flatten([
   for site_key, site in local.acisitelist : [
     for bd_key, bd in site.bds :
       {
         segment_name           = site.segment_name
         site_name              = site.site_name
         site_type              = site.type
         bd_name                = bd.name
         display_name           = bd.display_name
         layer2_stretch         = bd.layer2_stretch
         intersite_bum_traffic  = bd.intersite_bum_traffic
         subnets                = bd.subnets
       }
   ]
  ])
  acibdmap = {
    for val in local.acibdlist:
     // format("%s-%s", val["host_key"], val["network_name"]) => val
      lower(format("%s-%s-%", val["segment_name"], val["site_name"], val["bd_name"])) => val
  }

  acibdsublist = flatten([
   for bd_key, bd in local.acibdmap : [
     for sub_key, subnet in bd.subnets :
       {
         segment_name           = bd.segment_name
         site_name              = bd.site_name
         site_type              = bd.site_type
         bd_name                = bd.bd_name
         sub_id                 = sub_key
         ip                     = subnet.ip
         scope                  = subnet.scope
         description            = subnet.description
         shared                 = subnet.shared
         no_default_gateway     = subnet.no_default_gateway
         querier                = subnet.querier
       }
   ]
  ])
  acibdsubmap = {
    for val in local.acibdsublist:
     // format("%s-%s", val["host_key"], val["network_name"]) => val
      lower(format("%s-%s-%-%", val["segment_name"], val["site_name"], val["bd_name"], val["sub_key"])) => val
  }

}

output "sitemap" {
  value = local.sitemap
}

output "regionmap" {
  value = local.regionmap
}

output "acibdmap" {
  value = local.acibdmap
}

output "acibdsubmap" {
  value = local.acibdsubmap
}

## Bind Schema/Template to Sites ##
resource "mso_schema_site" "sites" {
  for_each = local.sitemap

  schema_id               = mso_schema.schema.id
  template_name           = mso_schema_template.segments[each.value.segment_name].name
  site_id                 = data.mso_site.sites[each.value.site_name].id # Site keys happen to be uppercase
}

## Bind Template VRF to Sites ##
resource "mso_schema_site_vrf" "vrf" {
  for_each = local.sitemap

  template_name           = mso_schema_template.segments[each.value.segment_name].name
  site_id                 = data.mso_site.sites[each.value.site_name].id # Site keys happen to be uppercase
  schema_id               = mso_schema.schema.id
  vrf_name                = mso_schema_template_vrf.segments[each.value.segment_name].name

  depends_on = [mso_schema_site.sites]
}

## Configure Site Regions ##
resource "mso_schema_site_vrf_region" "region" {
  for_each = local.regionmap

  schema_id               = mso_schema.schema.id
  template_name           = mso_schema_template.segments[each.value.segment_name].name
  site_id                 = data.mso_site.sites[each.value.site_name].id # Site keys happen to be uppercase
  vrf_name                = mso_schema_template_vrf.segments[each.value.segment_name].name
  region_name             = each.value.region_name
  vpn_gateway             = false
  hub_network_enable      = true
  hub_network = {
    name        = each.value.region_hub
    tenant_name = "infra"
  }

  dynamic "cidr" {
    for_each = each.value.region_cidrs
    content {
      cidr_ip = cidr.value.ip
      primary = cidr.value.primary

      dynamic "subnet" {
        for_each = cidr.value.subnets
        content {
          ip = subnet.value.ip
          zone = subnet.value.zone
          usage = subnet.value.usage
        }
      }
    }
  }

  depends_on = [mso_schema_site_vrf.vrf]
}

## Create On-Prem ACI Bridge Domains ##
resource "mso_schema_template_bd" "bd" {
  for_each = local.acibdmap

  schema_id               = mso_schema.schema.id
  template_name           = mso_schema_template.segments[each.value.segment_name].name
  vrf_name                = mso_schema_template_vrf.segments[each.value.segment_name].name

  name                    = each.value.bd_name
  display_name            = each.value.display_name
  layer2_stretch          = each.value.layer2_stretch
  intersite_bum_traffic   = each.value.intersite_bum_traffic
  layer2_unknown_unicast  = each.value.layer2_unknown_unicast

  // depends_on = [mso_schema_site.cpoc-syd]
}

## Create On-Prem ACI Bridge Domain Subnets ##
resource "mso_schema_template_bd_subnet" "subnet" {
  for_each = local.acibdsubmap

  schema_id               = mso_schema.schema.id
  template_name           = mso_schema_template.segments[each.value.segment_name].name

  bd_name                 = each.value.bd_name
  ip                      = each.value.ip
  scope                   = each.value.scope
  description             = each.value.description
  shared                  = each.value.shared
  no_default_gateway      = each.value.no_default_gateway
  querier                 = each.value.querier
}
