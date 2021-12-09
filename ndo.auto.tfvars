### Define Tenant ###
tenant = "Production"
schema_name = "Prod|MultiCloudDemo"
template_name = "Prod|Shared"

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
                    usage = "HR Apps #1"
                  }
                  sub4 = {
                    ip    = "10.1.2.64/28"
                    zone  = "ap-southeast-2b"
                    usage = "HR Apps #2"
                  }
                }
              }
            }
          }
        }
        bds = {}
      }
      cpoc-syd-dmz = {
        type = "aci"
        name = "CPOC-SYD-DMZ"
        regions = {}
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
  # engineering = {
  #   name = "Engineering"
  #   display_name = "HR"
  #   description = "Network Segment for Engineering Apps"
  # }
  }
}
