# BASIC EXAMPLE

  1. Creates resources required by module: Resource Group, Virtual Network
  2. Creates an example target resource (Storage Account)
  3. Creates a Private DNS zone (not required) for routing traffic via the private link internal address instead of the public address
  4. Module: Creates a private link (in a new subnet) to the example resource. Registers the IP address in the Private DNS for the virtual network.
