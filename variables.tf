////////////////////////
// External Resource References
////////////////////////

variable "virtual_network" {
  description = "Provide an existing virtual network for creating a private endpoint subnet."

  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "tags" {
  type = map(string)
  default = {}
}

////////////////////////
// Overrides | Subnet
////////////////////////

variable "subnet_name" {
  type    = string
  default = "private-link-endpoints"
}

variable "subnet_prefixes" {
  description = "Create subnet within provided external virtual network."
  
  type = object({
    vnet_index = optional(number, 0)
    newbits    = optional(number, 2)
    netnum     = optional(number, 0)
  })

  default = {}
}

////////////////////////
// Overrides | Security
////////////////////////

variable "security_rules" {
  type = list(object({
    name = string
    priority = number
  }))

  default = []
}

////////////////////////
// Endpoint
////////////////////////

variable "private_endpoints" {
  type = list(object({
    endpoint_name          = string
    connection_name        = string
    target_resource_id     = string
    allowed_subresources   = optional(list(string), [])
    private_dns_zone_group = optional(object({
      name     = string
      zone_ids = list(string)
    }), null)
  }))

  default = []
}
