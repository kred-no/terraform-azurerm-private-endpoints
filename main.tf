////////////////////////
// External Resources
////////////////////////

data "azurerm_virtual_network" {
  name                = var.virtual_network.name
  resource_group_name = var.virtual_network.resource_group_name
}

////////////////////////
// Subnet
////////////////////////

resource "azurerm_subnet" "MAIN" {
  name             = var.subnet_name
  address_prefixes = var.subnet_prefixes
  
  resource_group_name = data.azurerm_virtual_network.MAIN.resource_group_name
  location            = data.azurerm_virtual_network.MAIN.location
}

////////////////////////
// Security
////////////////////////
// TODO

////////////////////////
// Endpoints
////////////////////////

resource "azurerm_private_endpoint" "MAIN" {
  for_each = {
    for endpoint in var.endpoints: endpoint.name => endpoint
  }

  name = each.value["endpoint_name"]
  
  private_service_connection {
    name                           = each.value["connection_name"]
    private_connection_resource_id = each.value["target_resource_id"]
    subresource_names              = each.value["allowed_subresources"]
    is_manual_connection           = false
  }

  subnet_id           = azurerm_subnet.MAIN.id
  resource_group_name = data.azurerm_virtual_network.MAIN.resource_group_name
  location            = data.azurerm_virtual_network.MAIN.location
}