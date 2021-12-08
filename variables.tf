variable "segments" {
  type = map(object({
    name = string
    description = string
  }))
}
