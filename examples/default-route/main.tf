provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module  = "vnet"
    example = "default-route"
    usage   = "demo"
  }
  resource_prefix = "tfmex-default-route-vnet"
}

resource "azurerm_resource_group" "vnet" {
  name     = "rg-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_route_table" "vnet" {
  name                = "rt-default-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags

  disable_bgp_route_propagation = true
  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "172.16.1.1"
  }
}

module "vnet" {
  source = "../../"

  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
  subnets = {
    "default" = {
      prefix = "10.0.0.0/24"
    }
  }

  subnet_route_table_map = {
    "default" = azurerm_route_table.vnet.id
  }
}
