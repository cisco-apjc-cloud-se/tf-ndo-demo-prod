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
        cidr = string
        subnets = map(object({
          ip = string
          zone = string
          usage = string
          }))
        }))
      }))
  }))
}
