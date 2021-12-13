### Define Tenant ###
tenant = "Production"
schema_name = "Prod|MultiCloudDemo"
shared_template_name = "Prod|Shared" # shared template

# ### On-Premise Details ###
# aci_vmm_domain = "CPOC-SE-VC-HX"

### Enabled Sites for Templates  ###
sites = [
  "AWS-SYD",
  "AZURE-MEL",
  "CPOC-SYD-DMZ"
]

### Network Segments ###
segments = {
  hr = {
    name          = "hr"
    display_name  = "HR"
    description   = "Network Segment for HR Apps"
    sites = {
      aws-syd = {
        name = "AWS-SYD"  # NDO Site names happens to be capitalised
        type = "aws"
        regions = {
          ap-southeast-2 = {
            name = "ap-southeast-2"
            hub_name = "HUB1"
            cidrs = {
              cidr1 = {
                ip = "10.1.2.0/24"
                primary = true
                subnets = {
                  sub1 = {
                    ip    = "10.1.2.0/28"
                    zone  = "ap-southeast-2a"
                    usage = "gateway" # TGW Subnet #1
                  }
                  sub2 = {
                    ip    = "10.1.2.16/28"
                    zone  = "ap-southeast-2b"
                    usage = "gateway" # TGW Subnet #2
                  }
                  sub3 = {
                    ip    = "10.1.2.32/28"
                    zone  = "ap-southeast-2a"
                    # usage = "unspecified"
                  }
                  sub4 = {
                    ip    = "10.1.2.64/28"
                    zone  = "ap-southeast-2b"
                    # usage = "unspecified"
                  }
                  sub5 = {
                    ip    = "10.1.2.96/28"
                    zone  = "ap-southeast-2a"
                    # usage = "unspecified"
                  }
                }
              }
            }
          }
          ap-southeast-1 = {
            name = "ap-southeast-1"
            hub_name = "HUB1"
            cidrs = {
              cidr1 = {
                ip = "10.1.1.0/24"
                primary = true
                subnets = {
                  sub1 = {
                    ip    = "10.1.1.0/28"
                    zone  = "ap-southeast-1a"
                    usage = "gateway" # TGW Subnet #1
                  }
                  sub2 = {
                    ip    = "10.1.1.16/28"
                    zone  = "ap-southeast-1b"
                    usage = "gateway" # TGW Subnet #2
                  }
                  sub3 = {
                    ip    = "10.1.1.32/28"
                    zone  = "ap-southeast-1a"
                    # usage = "unspecified"
                  }
                  sub4 = {
                    ip    = "10.1.1.64/28"
                    zone  = "ap-southeast-1b"
                    # usage = "unspecified"
                  }
                }
              }
            }
          }
        }
        vmm_domain = ""
        bds = {}
      }
      cpoc-syd-dmz = {
        type = "aci"
        name = "CPOC-SYD-DMZ"
        regions = {}
        vmm_domain = "CPOC-SE-VC-HX"
        bds = {
          bd1 = {
            name                    = "tf-mcdemo-bd1"
            display_name            = "Multi-Cloud Demo HR Segment Bridge Domain #1"
            layer2_stretch          = true
            intersite_bum_traffic   = true
            layer2_unknown_unicast  = "proxy"
            subnets = {
              sub1 = {
                ip                  = "10.1.0.1/24"
                scope               = "private" # public
                description         = "HR Apps"
                shared              = false
                no_default_gateway  = false
                querier             = true
              }
            }
          }
        }
      }
    }
  }
}
