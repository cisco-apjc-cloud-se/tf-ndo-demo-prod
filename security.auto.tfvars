
filters = {
  allow-all = {
    name = "allow-all"
    display_name = "Allow All Traffic"
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
  allow-icmp = {
    name = "allow-icmp"
    display_name = "Allow ICMP Traffic"
    segment = "hr"
    entries = {
      entry1 = {
        name          = "any-icmp"
        display_name  = "Any ICMP"
        description   = "Allow any ICMP protocol traffic"
        ether_type    = "ip"
        ip_protocol   = "icmp"
        # destination_from = "unspecified"
        # destination_to = "unspecified"
        # source_from = "unspecified"
        # source_to = "unspecified"
      }
    }
  }
  allow-ssh = {
    name = "allow-ssh"
    display_name = "Allow SSH Traffic"
    segment = "hr"
    entries = {
      entry1 = {
        name          = "tcp-22"
        display_name  = "TCP 22"
        description   = "Allow SSH TCP 22"
        ether_type    = "ip"
        ip_protocol   = "tcp"
        destination_from = "ssh" # preset value
        destination_to = "ssh" # preset value
        # source_from = "unspecified"
        # source_to = "unspecified"
      }
    }
  }
  allow-sql = {
    name = "allow-sql"
    display_name = "Allow MySQL Traffic"
    segment = "hr"
    entries = {
      entry1 = {
        name          = "tcp-3306"
        display_name  = "TCP 3306"
        description   = "Allow MySQL TCP 3306"
        ether_type    = "ip"
        ip_protocol   = "tcp"
        destination_from = "3306"
        destination_to = "3306"
        # source_from = "unspecified"
        # source_to = "unspecified"
      }
    }
  }
  allow-web = {
    name = "allow-web"
    display_name = "Allow Web Traffic"
    segment = "hr"
    entries = {
      entry1 = {
        name          = "tcp-80"
        display_name  = "TCP 80"
        description   = "Allow HTTP TCP 80"
        ether_type    = "ip"
        ip_protocol   = "tcp"
        destination_from = "http" # preset value
        destination_to = "http" # preset value
        # source_from = "unspecified"
        # source_to = "unspecified"
      }
      entry2 = {
        name          = "tcp-443"
        display_name  = "TCP 443"
        description   = "Allow HTTPS TCP 443"
        ether_type    = "ip"
        ip_protocol   = "tcp"
        destination_from = "https" # preset value
        destination_to = "https" # preset value
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
      # allow-all = {
      #   name = "allow-all"
      #   # schema_id = "" # For shared/common filters
      #   # template_name = "" # For shared/common filters
      # }
      allow-web = {
        name = "allow-web"
      }
      allow-ssh = {
        name = "allow-ssh"
      }
      allow-icmp = {
        name = "allow-icmp"
      }
    }
  }
  public-hrapp2 = {
    name = "public-to-hr-app2"
    display_name = "Public-to-HR-App2"
    segment = "hr"
    filter_type = "bothWay"
    context = "context"
    directives = ["none"] # None or Log as List
    filters = {
      # allow-all = {
      #   name = "allow-all"
      #   # schema_id = "" # For shared/common filters
      #   # template_name = "" # For shared/common filters
      # }
      allow-web = {
        name = "allow-web"
      }
      allow-ssh = {
        name = "allow-ssh"
      }
      allow-icmp = {
        name = "allow-icmp"
      }
    }
  }
  hr-app1-web-to-db = {
    name = "hr-app1-web-to-db"
    display_name = "HR App #1 - Web to DB"
    segment = "hr"
    filter_type = "bothWay"
    context = "context"
    directives = ["none"] # None or Log as List
    filters = {
      allow-sql = {
        name = "allow-sql"
      }
      allow-icmp = {
        name = "allow-icmp"
      }
    }
  }
  hr-app2-web-to-db = {
    name = "hr-app2-web-to-db"
    display_name = "HR App #2 - Web to DB"
    segment = "hr"
    filter_type = "bothWay"
    context = "context"
    directives = ["none"] # None or Log as List
    filters = {
      allow-sql = {
        name = "allow-sql"
      }
      allow-icmp = {
        name = "allow-icmp"
      }
    }
  }
}


users = {
  cloud-public = {
    name = "cloud-public"
    display_name = "Cloud Public Internet"
    type = "cloud"
    sites = [
      "AWS-SYD",
      "AZURE-MEL"
      # "CPOC-SYD-DMZ"
    ]
    anp = "shared"
    segment = "hr"
    ip = "0.0.0.0/0"
    contracts = {
      cons1 = {
        name = "public-to-hr-app1"
        relationship_type = "consumer"
      }
      cons2 = {
        name = "public-to-hr-app2"
        relationship_type = "consumer"
      }
    }
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
          # sel1 = {
          #   name = "web"
          #   key = "Custom:EPG"
          #   operator = "equals"
          #   value = "hrapp1-web"
          # }
        }
        contracts = {
          prov1 = {
            name = "public-to-hr-app1"
            relationship_type = "provider"
          }
          cons1 = {
            name = "hr-app1-web-to-db"
            relationship_type = "consumer"
          }
        }
      }
      db = {
        name = "db"
        display_name = "Database Tier"
        bd_name = "tf-mcdemo-bd1" # "unspecified"
        selectors = {
          # sel1 = {
          #   name = "db"
          #   key = "Custom:EPG"
          #   operator = "equals"
          #   value = "hrapp1-db"
          # }
        }
        contracts = {
          prov1 = {
            name = "hr-app1-web-to-db"
            relationship_type = "provider"
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
          # sel1 = {
          #   name = "web"
          #   key = "Custom:EPG"
          #   operator = "equals"
          #   value = "hrapp2-web"
          # }
        }
        contracts = {
          prov1 = {
            name = "public-to-hr-app2"
            relationship_type = "provider"
          }
          cons1 = {
            name = "hr-app2-web-to-db"
            relationship_type = "consumer"
          }
        }
      }
      db = {
        name = "db"
        display_name = "Database Tier"
        bd_name = "tf-mcdemo-bd1" # "unspecified"
        selectors = {
          # sel1 = {
          #   name = "db"
          #   key = "Custom:EPG"
          #   operator = "equals"
          #   value = "hrapp2-db"
          # }
        }
        contracts = {
          prov1 = {
            name = "hr-app2-web-to-db"
            relationship_type = "provider"
          }
        }
      }
    }
  }
}
