
filters = {
  allow-all = {
    name = "allow-all"
    display_name = "Allow All"
    segment = "hr"
    entries = {
      entry1 = {
        name          = "any-ip"
        display_name  = "Any IP"
        description   = "Allow any IP protocol traffic"
        ether_type    = "ip"
        # ip_protocol = "unspecified"
        # destination_from = "unspecified"
        # destination_to = "unspecified"
        # source_from = "unspecified"
        # source_to = "unspecified"
      }
    }
  }
}


contracts = {
  public-hrapp1 = {
    name = "public-to-hr-app1"
    display_name = "Public-to-HR-App1"
    segment = "hr"
    filter_type = "bothWay"
    context = "context"
    directives = ["none"] # None or Log as List
    filters = {
      allow-all = {
        name = "allow-all"
        # schema_id = "" # For shared/common filters
        # template_name = "" # For shared/common filters
      }
    }

    # providers = []
    # consumers = []
  }
}


users = {
  cloud-public = {
    name = "cloud-public"
    display_name = "Cloud Public Internet"
    type = "cloud"
    sites = [
      "AWS-SYD"
      # "AZURE-MEL"
      # "CPOC-SYD-DMZ"
    ]
    anp = "shared"
    segment = "hr"
    ip = "0.0.0.0/0"
  }
}

applications = {
  shared = {
    name = "shared"
    display_name = "Shared Applications and User Groups"
    segment = "hr"  ## shared template
    epgs = {}
  }
  hrapp1 = {
    name = "hrapp1"
    display_name = "HR App Profile #1"
    segment = "hr"  # a.k.a segment and VRF
    epgs = {
      web = {
        name = "web"
        display_name = "Web Tier"
        bd_name = "tf-mcdemo-bd1" # "unspecified"
        # useg_enabled = false
        # intra_epg = "unenforced"
        # intersite_multicast_source = false
        # preferred_group = false
        selectors = {
          sel1 = {
            name = "web"
            key = "Custom:EPG"
            operator = "equals"
            value = "web"
          }
        }
      }
      db = {
        name = "db"
        display_name = "Database Tier"
        bd_name = "tf-mcdemo-bd1" # "unspecified"
        selectors = {
          sel1 = {
            name = "db"
            key = "Custom:EPG"
            operator = "equals"
            value = "db"
          }
        }
      }
    }
  }
  hrapp2 = {
    name = "hrapp2"
    display_name = "HR App Profile #2"
    segment = "hr"  # a.k.a segment and VRF
    epgs = {
      web = {
        name = "web"
        display_name = "Web Tier"
        bd_name = "tf-mcdemo-bd1" # "unspecified"
        selectors = {
          sel1 = {
            name = "web"
            key = "Custom:EPG"
            operator = "equals"
            value = "web"
          }
        }
      }
      db = {
        name = "db"
        display_name = "Database Tier"
        bd_name = "tf-mcdemo-bd1" # "unspecified"
        selectors = {
          sel1 = {
            name = "db"
            key = "Custom:EPG"
            operator = "equals"
            value = "db"
          }
        }
      }
    }
  }
}
