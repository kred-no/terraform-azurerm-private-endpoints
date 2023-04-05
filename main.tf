////////////////////////
// External Resources
////////////////////////

data "azurerm_virtual_network" "MAIN" {
  name                = var.virtual_network.name
  resource_group_name = var.virtual_network.resource_group_name
}

////////////////////////
// Subnet
////////////////////////

resource "azurerm_subnet" "MAIN" {
  name             = var.subnet_name
  
  address_prefixes = [cidrsubnet(
    element(data.azurerm_virtual_network.MAIN.address_space, var.subnet_prefixes.vnet_index),
    var.subnet_prefixes.newbits,
    var.subnet_prefixes.netnum,
  )]
  
  virtual_network_name = data.azurerm_virtual_network.MAIN.name 
  resource_group_name  = data.azurerm_virtual_network.MAIN.resource_group_name
}

////////////////////////
// Security
////////////////////////

resource "azurerm_network_security_group" "MAIN" {
  count = length(var.security_rules) > 0 ? 1 : 0
  
  name = var.subnet_name
  
  dynamic "security_rule" {
    for_each = var.security_rules
    
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }

  tags                = var.tags
  resource_group_name = data.azurerm_virtual_network.MAIN.resource_group_name
  location            = data.azurerm_virtual_network.MAIN.location
}

////////////////////////
// Endpoints
////////////////////////

resource "azurerm_private_endpoint" "MAIN" {
  for_each = {
    for endpoint in var.private_endpoints: endpoint.endpoint_name => endpoint
  }

  name = each.value["endpoint_name"]
  
  private_service_connection {
    name                           = each.value["connection_name"]
    private_connection_resource_id = each.value["target_resource_id"]
    subresource_names              = each.value["allowed_subresources"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value["private_dns_zone_group"][*] // Ref. https://developer.hashicorp.com/terraform/language/expressions/splat#single-values-as-lists
    
    content {
      name                 = private_dns_zone_group.value["name"]
      private_dns_zone_ids = private_dns_zone_group.value["zone_ids"]
    }
  }

  subnet_id           = azurerm_subnet.MAIN.id
  resource_group_name = data.azurerm_virtual_network.MAIN.resource_group_name
  location            = data.azurerm_virtual_network.MAIN.location
}