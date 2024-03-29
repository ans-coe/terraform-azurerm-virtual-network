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
    example = "basic"
    usage   = "demo"
  }
  resource_prefix = "tfmex-basic-vnet"
}

resource "azurerm_resource_group" "vnet" {
  name     = "rg-${local.resource_prefix}"
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
  subnets = {
    "default" = {
      prefix = "10.0.0.0/24"
    }
  }
}
