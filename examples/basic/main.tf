provider "azurerm" {
  features {}
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

module "vnet" {
  source = "../../"

  name     = "${local.resource_prefix}-vnet"
  location = local.location
  tags     = local.tags

  address_space = ["10.0.0.0/16"]
  subnets = [
    {
      name   = "default"
      prefix = "10.0.0.0/24"
    }
  ]
}
