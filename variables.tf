////////////////////////
// External Resource References
////////////////////////

variable "virtual_network" {
  description = "Provide an existing virtual network for creating new network resources."

  type = object({
    name                = string
    resource_group_name = string
  })
}

////////////////////////
// Overrides | Subnet
////////////////////////

variable "subnet_name" {
  type    = string
  default = "private-link-endpoints"
}

variable "subnet_prefixes" {
  description = "-Required-"
  
  type = list(string)
}

////////////////////////
// Overrides | Security
////////////////////////

////////////////////////
// Endpoint
////////////////////////

variable "private_endpoints" {
  type = list(object({
    endpoint_name        = string
    connection_name      = string
    target_resource_id   = string
    allowed_subresources = optional(list(string), [])
  }))

  default = []
}
