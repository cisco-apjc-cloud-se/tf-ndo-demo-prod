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
            cidr = "10.1.2.0/24"
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
                usage = ""
              }
              sub4 = {
                ip    = "10.1.2.64/28"
                zone  = "ap-southeast-2b"
                usage = ""
              }
            }
          }
        }
      }
      # cpoc-dmz = {
      #   type = "aci"
      #   name = "cpoc-dmz"
      #   regions = []
      # }
    }
  # engineering = {
  #   name = "Engineering"
  #   display_name = "HR"
  #   description = "Network Segment for Engineering Apps"
  # }
  }
}
