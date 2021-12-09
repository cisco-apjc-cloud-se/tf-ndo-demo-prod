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
   flatlist = flatten([
    for seg_key, segment in var.segments : [
      for site_key, site in segment.sites  :
        {
          segment_name  = segment.name
          site_name     = site.name
          site          = site
        }
    ]
  ])
  sitemap = {
    for val in local.flatlist:
      // format("%s-%s", val["host_key"], val["network_name"]) => val
      lower(format("%s-%s", val["segment_name"], val["site_name"])) => val
  }
 //  awslist = flatten([
 //   for seg_key, segment in var.segments : [
 //     for site_key, site in segment.sites  :
 //       site.type == "aws" ? {
 //         segment_name  = segment.name
 //         site_name     = site.name
 //         site          = site
 //       }: null
 //   ]
 // ])
 // awsmap = {
 //   for val in local.awslist:
 //     // format("%s-%s", val["host_key"], val["network_name"]) => val
 //     lower(format("%s-%s", val["segment_name"], val["site_name"])) => val
 // }
}

output "test" {
  value = local.sitemap
}

## Bind Schema/Template to Sites ##
resource "mso_schema_site" "test" {
  // for_each = local.sitemap

  schema_id               = mso_schema.schema.id
  template_name           = "hr"
  site_id                 = data.mso_site.sites["AWS-SYD"].id
  // site_id                 = data.mso_site.sites[each.value.site_name].id # Site keys happen to be uppercase
}

// ## Bind Template VRF to Sites ##
//
// resource "mso_schema_site_vrf" "aws-syd" {
//   for_each = local.awsmap
//
//   template_name           = mso_schema_template.segments[each.value.segment_name].name
//   site_id                 = data.mso_site.AWS-SYD.id
//   schema_id               = mso_schema.ndo-demo-prod.id
//   vrf_name                = mso_schema_template_vrf.segments[each.value.segment_name].name
//
//   depends_on = [mso_schema_site.aws-syd]
// }
//
// ## Configure AWS Regions ##
//
// resource "mso_schema_site_vrf_region" "aws-syd" {
//   for_each = local.awsmap
//
//   schema_id               = mso_schema.tfcb-mc-demo.id
//   template_name           = mso_schema.tfcb-mc-demo.template_name
//   site_id                 = data.mso_site.AWS-SYD.id
//   vrf_name                = mso_schema_template_vrf.tfcb-mc-prod.name
//   region_name             = "ap-southeast-2"
//   vpn_gateway             = false
//   hub_network_enable      = true
//   hub_network = {
//     name        = "HUB1"
//     tenant_name = "infra"
//   }
//   cidr {
//     cidr_ip = "10.111.0.0/16"
//     primary = true
//     subnet {
//       ip    = "10.111.1.0/24"
//       zone  = "ap-southeast-2a"
//       usage = "gateway"
//     }
//     subnet {
//       ip    = "10.111.2.0/24"
//       zone  = "ap-southeast-2b"
//       usage = "gateway"
//     }
//     subnet {
//       ip    = "10.111.3.0/24"
//       zone  = "ap-southeast-2a"
//     }
//     subnet {
//       ip    = "10.111.4.0/24"
//       zone  = "ap-southeast-2b"
//     }
//   }
//   depends_on = [mso_schema_site_vrf.aws-syd]
// }
//
// ## Azure Site & VRF/VPCs Definitions
//
// resource "mso_schema_site" "azure-mel" {
//   schema_id               = mso_schema.tfcb-mc-demo.id
//   template_name           = mso_schema.tfcb-mc-demo.template_name
//   site_id                 = data.mso_site.AZURE-MEL.id
// }
//
// resource "mso_schema_site_vrf" "azure-mel" {
//   template_name           = mso_schema.tfcb-mc-demo.template_name
//   site_id                 = data.mso_site.AZURE-MEL.id
//   schema_id               = mso_schema.tfcb-mc-demo.id
//   vrf_name                = mso_schema_template_vrf.tfcb-mc-prod.name
//
//   depends_on = [mso_schema_site.azure-mel]
// }
//
// resource "mso_schema_site_vrf_region" "azure-mel" {
//   schema_id               = mso_schema.tfcb-mc-demo.id
//   template_name           = mso_schema.tfcb-mc-demo.template_name
//   site_id                 = data.mso_site.AZURE-MEL.id
//   vrf_name                = mso_schema_template_vrf.tfcb-mc-prod.name
//   region_name             = "australiasoutheast"
//   vpn_gateway             = false
//   hub_network_enable      = true
//   hub_network = {
//     name        = "Default"
//     tenant_name = "infra"
//   }
//   cidr {
//     cidr_ip = "10.112.0.0/16"
//     primary = true
//     subnet {
//       ip    = "10.112.1.0/24"
//       # zone  = ""
//       # usage = ""
//     }
//     subnet {
//       ip    = "10.112.2.0/24"
//       # zone  = ""
//       # usage = ""
//     }
//     subnet {
//       ip    = "10.112.3.0/24"
//       # zone  = ""
//     }
//     subnet {
//       ip    = "10.112.4.0/24"
//       # zone  = ""
//     }
//   }
//   depends_on = [mso_schema_site_vrf.azure-mel]
// }
//
//
// # ### Associate Template to Sites ###
// # v0.1.5 still broken
// # Error: "Bad Request: Patch Failed, Received: VRF 'tfcb-mc-prod' associated to site 'AZURE-MEL' should either have a Region associated to it or should be a Hosted VRF(Associated to Subnet/CIDR of a VRF configured in the Region). exception while trying to update schema"{}
//
//
// # ## AWS VRF WORKAROUND
// # resource "mso_rest" "vrf-workaround-aws" {
// #     path = "api/v1/schemas/${mso_schema.tfcb-mc-demo.id}"
// #     method = "PATCH"
// #     payload = <<EOF
// # [
// #   {
// #     "op": "add",
// #     "path": "/sites/-",
// #     "value": {
// #       "siteId": "${data.mso_site.AWS-SYD.id}",
// #       "templateName": "${mso_schema.tfcb-mc-demo.template_name}",
// #       "vrfs": [{
// #         "vrfRef": {
// #           "schemaId": "${mso_schema.tfcb-mc-demo.id}",
// #           "templateName": "${mso_schema.tfcb-mc-demo.template_name}",
// #           "vrfName": "${mso_schema_template_vrf.tfcb-mc-prod.name}"
// #         },
// #         "regions": [{
// #           "name": "ap-southeast-2",
// #           "cidrs": [{
// #             "ip": "10.111.0.0/16",
// #             "primary": true,
// #             "subnets": [
// #               {
// #               "ip": "10.111.1.0/24",
// #               "zone": "ap-southeast-2a",
// #               "name": "",
// #               "usage": "gateway"
// #               },
// #               {
// #               "ip": "10.111.2.0/24",
// #               "zone": "ap-southeast-2b",
// #               "name": "",
// #               "usage": "gateway"
// #               },
// #               {
// #               "ip": "10.111.3.0/24",
// #               "zone": "ap-southeast-2a",
// #               "name": ""
// #               },
// #               {
// #               "ip": "10.111.4.0/24",
// #               "zone": "ap-southeast-2b",
// #               "name": ""
// #               }
// #             ],
// #             "associatedRegion": "ap-southeast-2"
// #           }],
// #           "isVpnGatewayRouter": false,
// #           "isTGWAttachment": true,
// #           "cloudRsCtxProfileToGatewayRouterP": {
// #             "name": "HUB1",
// #             "tenantName": "infra"
// #           },
// #           "hubnetworkPeering": false
// #         }]
// #       }],
// #       "intersiteL3outs": null
// #     }
// #   }
// # ]
// # EOF
// #
// # }
//
// # ## AZURE VRF WORKAROUND
// # resource "mso_rest" "vrf-workaround-azure" {
// #     path = "api/v1/schemas/${mso_schema.tfcb-mc-demo.id}"
// #     method = "PATCH"
// #     payload = <<EOF
// # [
// #   {
// #     "op": "add",
// #     "path": "/sites/-",
// #     "value": {
// #       "siteId": "${data.mso_site.AZURE-MEL.id}",
// #       "templateName": "${mso_schema.tfcb-mc-demo.template_name}",
// #       "vrfs": [{
// #         "vrfRef": {
// #           "schemaId": "${mso_schema.tfcb-mc-demo.id}",
// #           "templateName": "${mso_schema.tfcb-mc-demo.template_name}",
// #           "vrfName": "${mso_schema_template_vrf.tfcb-mc-prod.name}"
// #         },
// #         "regions": [{
// #           "name": "australiasoutheast",
// #           "cidrs": [{
// #             "ip": "10.112.0.0/16",
// #             "primary": true,
// #             "subnets": [
// #               {
// #               "ip": "10.112.1.0/24",
// #               "zone": "",
// #               "name": ""
// #               },
// #               {
// #               "ip": "10.112.2.0/24",
// #               "zone": "",
// #               "name": ""
// #               },
// #               {
// #               "ip": "10.112.3.0/24",
// #               "zone": "",
// #               "name": ""
// #               },
// #               {
// #               "ip": "10.112.4.0/24",
// #               "zone": "",
// #               "name": ""
// #               }
// #             ],
// #             "associatedRegion": "australiasoutheast"
// #           }],
// #           "cloudRsCtxProfileToGatewayRouterP": {
// #                 "name": "default",
// #                 "tenantName": "infra"
// #               },
// #           "isVpnGatewayRouter": false,
// #           "isTGWAttachment": true,
// #           "hubnetworkPeering": false
// #         }]
// #       }],
// #       "intersiteL3outs": null
// #     }
// #   }
// # ]
// # EOF
// #
// # }
//
// ### CPOC DMZ ACI Fabric ###
// resource "mso_schema_site" "cpoc-syd" {
//   schema_id               = mso_schema.tfcb-mc-demo.id
//   template_name           = mso_schema.tfcb-mc-demo.template_name
//   site_id                 = data.mso_site.CPOC-SYD.id
// }
//
// resource "mso_schema_template_bd" "tfcb-mc-bd1" {
//   schema_id               = mso_schema.tfcb-mc-demo.id
//   template_name           = mso_schema.tfcb-mc-demo.template_name
//   name                    = "tfcb-mc-bd1"
//   display_name            = "Multi-Cloud Demo Bridge Domain #1"
//   vrf_name                = mso_schema_template_vrf.tfcb-mc-prod.name
//   layer2_stretch          = true
//   intersite_bum_traffic   = true
//   # layer2_unknown_unicast = "proxy"
//
//   depends_on = [mso_schema_site.cpoc-syd]
// }
//
// resource "mso_schema_template_bd_subnet" "tfcb-mc-bd-sub1" {
//   schema_id               = mso_schema.tfcb-mc-demo.id
//   template_name           = mso_schema.tfcb-mc-demo.template_name
//   bd_name                 = mso_schema_template_bd.tfcb-mc-bd1.name
//   ip                      = "10.113.1.24/24"
//   scope                   = "public"
//   description             = "Production Subnet #1"
//   shared                  = true
//   # no_default_gateway      = false
//   # querier                 = true
// }
