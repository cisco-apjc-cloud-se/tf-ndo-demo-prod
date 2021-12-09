variable "tenant" {
  type = string
}

variable "schema_name" {
  type = string
}

variable "template_name" {
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
            usage = string ## Required but not used except for gateway - needs to be >0 length
            }))
          }))
        }))
      }))
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
}
