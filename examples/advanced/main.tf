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
    example = "advanced"
    usage   = "demo"
  }
  resource_prefix = "tfmex-adv-vnet"
}

resource "azurerm_resource_group" "vnet" {
  name     = "${local.resource_prefix}-rg"
  location = local.location
  tags     = local.tags
}

module "vnet" {
  source = "../../"

  name                = "${local.resource_prefix}-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
  # ddos_protection_plan_id = azurerm_network_ddos_protection_plan.vnet.id
  subnets = {
    "default" = {
      prefix            = "10.0.0.0/24"
      service_endpoints = ["Microsoft.Storage"]
    }

    "private-links" = {
      prefix                                        = "10.0.1.0/24"
      service_endpoints                             = ["Microsoft.Storage"]
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = true
    }

    "appservice" = {
      prefix            = "10.0.11.0/24"
      service_endpoints = ["Microsoft.Storage"]
      delegations = {
        appservice = {
          service = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }

    "blackhole" = {
      prefix = "10.0.255.0/24"
    }
  }

  subnet_network_security_group_map = {
    "blackhole" = azurerm_network_security_group.vnet.id
  }

  subnet_route_table_map = {
    "blackhole" = azurerm_route_table.vnet.id
  }

  subnet_nat_gateway_map = {
    "default" = azurerm_nat_gateway.vnet.id
  }

  peer_networks = {
    (module.vnet_peer.name) = {
      id = module.vnet_peer.id
    }
  }

  private_dns_zones = {
    (azurerm_private_dns_zone.vnet.name) = {
      resource_group_name = azurerm_private_dns_zone.vnet.resource_group_name
    }
  }
}

module "vnet_peer" {
  source = "../../"

  name                = "${local.resource_prefix}-peer-vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags

  address_space = ["10.1.0.0/16"]
  subnets = {
    "default" = {
      prefix = "10.1.0.0/24"
    }
  }

  peer_networks = {
    (module.vnet.name) = {
      id = module.vnet.id
    }
  }
}

# ddos protection plans are expensive so this has been commented out
# resource "azurerm_network_ddos_protection_plan" "vnet" {
#   name                = "${local.resource_prefix}-ddos-plan"
#   location            = local.location
#   resource_group_name = azurerm_resource_group.vnet.name
#   tags                = local.tags
# }

resource "azurerm_private_dns_zone" "vnet" {
  name                = "example.com"
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "vnet" {
  name                = "${local.resource_prefix}-nsg"
  location            = local.location
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags
}

resource "azurerm_route_table" "vnet" {
  name                = "${local.resource_prefix}-blackhole-rt"
  location            = local.location
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags

  route {
    name           = "blackhole"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "None"
  }
}

resource "azurerm_public_ip" "vnet" {
  name                = "${local.resource_prefix}-ngw-pip"
  location            = local.location
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags

  sku               = "Standard"
  allocation_method = "Static"
}

resource "azurerm_nat_gateway" "vnet" {
  name                = "${local.resource_prefix}-ngw"
  location            = local.location
  resource_group_name = azurerm_resource_group.vnet.name
  tags                = local.tags
}

resource "azurerm_nat_gateway_public_ip_association" "vnet" {
  nat_gateway_id       = azurerm_nat_gateway.vnet.id
  public_ip_address_id = azurerm_public_ip.vnet.id
}

output "subnets" {
  description = "Created subnets."
  value       = module.vnet.subnets
}
