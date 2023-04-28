#################
# Resource Group
#################

resource "azurerm_resource_group" "main" {
  count = var.resource_group_name == null ? 1 : 0

  name     = "${var.name}-rg"
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = coalesce(one(azurerm_resource_group.main[*].name), var.resource_group_name)
}

##################
# Virtual Network
##################

resource "azurerm_virtual_network" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  address_space = var.address_space

  bgp_community = var.bgp_community
  dynamic "ddos_protection_plan" {
    for_each = toset(var.ddos_protection_plan_id == null ? [] : [1])

    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }
}

resource "azurerm_virtual_network_dns_servers" "main" {
  virtual_network_id = azurerm_virtual_network.main.id
  dns_servers        = var.dns_servers
}

resource "azurerm_virtual_network_peering" "main" {
  for_each = { for p in var.peer_networks : p.name => p }

  name                      = format("%s_to_%s", azurerm_virtual_network.main.name, each.value["name"])
  virtual_network_name      = azurerm_virtual_network.main.name
  resource_group_name       = local.resource_group_name
  remote_virtual_network_id = each.value["id"]

  allow_virtual_network_access = each.value["allow_virtual_network_access"]
  allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
  allow_gateway_transit        = each.value["allow_gateway_transit"]
  use_remote_gateways          = each.value["use_remote_gateways"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = { for l in var.private_dns_zones : l.name => l }

  name                  = azurerm_virtual_network.main.name
  resource_group_name   = each.value["resource_group_name"]
  tags                  = var.tags
  virtual_network_id    = azurerm_virtual_network.main.id
  private_dns_zone_name = each.value["name"]

  registration_enabled = each.value["registration_enabled"]
}

##########
# Subnets
##########

resource "azurerm_subnet" "main" {
  for_each = { for s in var.subnets : s.name => s }

  name                 = each.value["name"]
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = local.resource_group_name

  address_prefixes = [each.value["prefix"]]

  service_endpoints                             = each.value["service_endpoints"]
  private_endpoint_network_policies_enabled     = each.value["private_endpoint_network_policies_enabled"]
  private_link_service_network_policies_enabled = each.value["private_link_service_network_policies_enabled"]

  dynamic "delegation" {
    for_each = each.value["delegations"] == null ? {} : each.value["delegations"]

    content {
      name = delegation.key

      service_delegation {
        name    = delegation.value["name"]
        actions = delegation.value["actions"]
      }
    }
  }
}

# Associations

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = var.subnet_network_security_group_map

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = each.value
}

resource "azurerm_subnet_route_table_association" "main" {
  for_each = var.subnet_route_table_map

  subnet_id      = azurerm_subnet.main[each.key].id
  route_table_id = each.value
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  for_each = var.subnet_nat_gateway_map

  subnet_id      = azurerm_subnet.main[each.key].id
  nat_gateway_id = each.value
}
