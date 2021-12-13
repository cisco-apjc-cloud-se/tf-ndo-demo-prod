variable "tenant" {
  type = string
}

variable "schema_name" {
  type = string
}

variable "shared_template_name" {
  type = string
}

variable "sites" {
  type = list(string)
}

variable "segments" {
  type = map(object({
    name = string
    description = string
    display_name = string
    sites = map(object({
      name = string
      type = string
      regions = map(object({
        name = string
        hub_name = string
        cidrs = map(object({
          ip      = string
          primary = bool
          subnets = map(object({
            ip    = string
            zone  = string
            usage = optional(string) ## Required but not used except for gateway - needs to be >0 length
          }))
        }))
      }))
      vmm_domain = string
      bds = map(object({
        name = string
        display_name = string
        layer2_stretch = bool
        intersite_bum_traffic = bool
        layer2_unknown_unicast = string
        subnets = map(object({
          ip                  = string
          scope               = string
          description         = string
          shared              = bool
          no_default_gateway  = bool
          querier             = bool
        }))
      }))
    }))
  }))
}

// variable "aci_vmm_domain" {
//   type = string
// }

variable "applications" {
  type = map(object({
    name = string
    display_name = string
    segment = string
    epgs = map(object({
      name = string
      display_name = string
      bd_name = string
      // useg_enabled = bool
      // intra_epg = string
      // intersite_multicast_source = bool
      // preferred_group = bool
      selectors = map(object({
        name = string
        key = string
        operator = string
        value = string
        }))
    }))
  }))
}

variable "users" {
  type = map(object({
    name = string
    display_name = string
    type = string
    sites = list(string)
    anp = string
    segment = string
    ip = string
  }))
}


variable "contracts" {
  type = map(object({
    name = string
    display_name = string
    filter_type = string
    context = string
    directives = list(string)
    filters = map(object({
      name = string
    }))
  }))
}

variable "filters" {
  type = map(object({
    name = string
    display_name = string
    entries = map(object({
      name = string
      display_name = string
      description = string
      ether_type = string
      ip_protocol = optional(string)
      destination_from = optional(string)
      destination_to = optional(string)
      source_from = optional(string)
      source_to = optional(string)
    }))
  }))
}
