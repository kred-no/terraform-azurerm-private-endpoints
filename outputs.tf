output "endpoint_ip_adresses" {
  description = "To be improved. Exports all the private ip-adresses as a basic list."
  sensitive = false
  
  value = [
    for endpoint in azurerm_private_endpoint.MAIN: endpoint.private_service_connection.0.private_ip_address
  ]
}
