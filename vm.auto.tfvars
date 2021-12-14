aws_apps = {
  hrapp1 = {
    name = "hrapp1" # ANP name
    segment = "hr" # VRF name
    regions = {
      ap-southeast-2 = {
        name = "ap-southeast-2"
        vpc_cidr = "10.1.2.0/24"
        instances = {
          web = {
            tier = "web" # EPG
            subnet_cidr = "10.1.2.32/28"
            instance_name = "hrapp1-web"
            instance_count = 2
          }
          db = {
            tier = "db" # EPG
            subnet_cidr = "10.1.2.48/28"
            instance_name = "hrapp1-db"
            instance_count = 1
          }
        }
      }
    }
  }
}

azure_apps = {
  hrapp1 = {
    name = "hrapp1" # ANP name
    segment = "hr" # VRF name
    regions = {
      australiasoutheast = {
        name = "australiasoutheast"
        vpc_cidr = "10.2.2.0/24"
        instances = {
          web = {
            tier = "web" # EPG
            subnet_cidr = "10.2.2.32/28"
            instance_name = "hrapp1-web"
            instance_count = 1
          }
          db = {
            tier = "db" # EPG
            subnet_cidr = "10.2.2.48/28"
            instance_name = "hrapp1-db"
            instance_count = 1
          }
        }
      }
    }
  }
}
