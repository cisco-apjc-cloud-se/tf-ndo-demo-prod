

applications = {
  hrapp1 = {
    name = "hrapp1"
    display_name = "HR App Profile #1"
    template = "hr"  # a.k.a segment and VRF
    epgs = {
      web = {
        name = "web"
        display_name = "Web Tier"
        bd_name = "unspecified"
        useg_enabled = false
        intra_epg = "unenforced"
        intersite_multicast_source = false
        preferred_group = false
      }
      db = {
        name = "db"
        display_name = "Database Tier"
        bd_name = "unspecified"
        useg_enabled = false
        intra_epg = "unenforced"
        intersite_multicast_source = false
        preferred_group = false
      }
    }
  }
  hrapp2 = {
    name = "hrapp2"
    display_name = "HR App Profile #2"
    template = "hr"  # a.k.a segment and VRF
    epgs = {
      web = {
        name = "web"
        display_name = "Web Tier"
        bd_name = "unspecified"
        useg_enabled = false
        intra_epg = "unenforced"
        intersite_multicast_source = false
        preferred_group = false
      }
      db = {
        name = "db"
        display_name = "Database Tier"
        bd_name = "unspecified"
        useg_enabled = false
        intra_epg = "unenforced"
        intersite_multicast_source = false
        preferred_group = false
      }
    }
  }
}
