//////////////////////////////////
// Core Resources
//////////////////////////////////

resource "random_id" "X" {
  keepers = {
    prefix = var.resource_group.prefix
  }

  byte_length = 3
}

resource "azurerm_resource_group" "MAIN" {
  name     = join("-", [random_id.X.keepers.prefix, random_id.X.hex])
  location = var.resource_group.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "MAIN" {
  name          = var.virtual_network.name
  address_space = var.virtual_network.address_space
  
  resource_group_name = azurerm_resource_group.MAIN.name
  location            = azurerm_resource_group.MAIN.location
}

//////////////////////////////////
// Private Link | Target Resource
//////////////////////////////////

resource "azurerm_storage_account" "MAIN" {
  name = join("", ["sa", random_id.X.hex ])
  
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
  
  resource_group_name = azurerm_resource_group.MAIN.name
  location            = azurerm_resource_group.MAIN.location
}

//////////////////////////////////
// Private DNS Zone
//////////////////////////////////

# See https://learn.microsoft.com/nb-no/azure/private-link/private-endpoint-dns#virtual-network-and-on-premises-workloads-using-a-dns-forwarder
resource "azurerm_private_dns_zone" "MAIN" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.MAIN.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "MAIN" {
  name = join("-", [azurerm_virtual_network.MAIN.name, "plinks"])
  
  private_dns_zone_name = azurerm_private_dns_zone.MAIN.name
  virtual_network_id    = azurerm_virtual_network.MAIN.id
  resource_group_name   = azurerm_resource_group.MAIN.name
}

//////////////////////////////////
// Module Config
//////////////////////////////////

module "private-endpoints" {
  source = "./../../../terraform-azurerm-private-endpoints"

  // Customize
  private_endpoints = [{
    endpoint_name        = "basic-blob-pe"
    connection_name      = "basic-blob-connection"
    target_resource_id   = azurerm_storage_account.MAIN.id
    allowed_subresources = ["blob"]
    private_dns_zone_group = {
      name     = "dns-config-plink"
      zone_ids = [azurerm_private_dns_zone.MAIN.id]
    }
  }]

  // External Resource References
  virtual_network = azurerm_virtual_network.MAIN
}
