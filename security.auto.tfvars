

applications = {
  hrapp1 = {
    name = "hrapp1"
    display_name = "HR App Profile #1"
    template = "hr"  # a.k.a segment and VRF
    epgs = {
      web = {
        name = "web"
        display_name = "Web Tier"
      }
      db = {
        name = "db"
        display_name = "Database Tier"
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
      }
      db = {
        name = "db"
        display_name = "Database Tier"
      }
    }
  }
}
