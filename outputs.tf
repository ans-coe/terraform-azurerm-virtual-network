output "id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "location" {
  description = "Location of the virtual network."
  value       = azurerm_virtual_network.main.location
}

output "name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.main.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = var.resource_group_name
}

output "address_space" {
  description = "Address space of the virtual network."
  value       = azurerm_virtual_network.main.address_space
}

output "subnets" {
  description = "Subnet configuration."
  value = {
    for s in azurerm_subnet.main
    : s.name => {
      name                      = s.name
      prefix                    = one(s.address_prefixes)
      id                        = s.id
      network_security_group_id = try(azurerm_subnet_network_security_group_association.main[s.name].network_security_group_id, null)
      route_table_id            = try(azurerm_subnet_route_table_association.main[s.name].route_table_id, null)
      nat_gateway_id            = try(azurerm_subnet_nat_gateway_association.main[s.name].nat_gateway_id, null)
    }
  }
}
