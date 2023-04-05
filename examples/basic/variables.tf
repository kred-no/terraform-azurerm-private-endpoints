variable "subscription_id" {
  type    = string
  default = null
}

variable "tenant_id" {
  type    = string
  default = null
}

variable "tags" {
  type = map(string)
  
  default = {
    url = "https://github.com/kred-no/terraform-azurerm-private-endpoints"
  }
}

variable "resource_group" {
  type    = object({
    prefix   = optional(string, "TfBasicExample")
    location = optional(string, "northeurope")
  })
  
  default = {}
}

variable "virtual_network" {
  type    = object({
    name          = optional(string, "ExampleVNet")
    address_space = optional(list(string), ["192.168.168.0/24"])
  })
  
  default = {}
}

variable "module" {
  type = object({
    subnet_name = optional(string, "PrivateEndpoints")
    subnet_vnet_index = optional(number, 0)
    subnet_newbits    = optional(number, 3)
    subnet_number     = optional(number, 0)
  })

  default = {}
}