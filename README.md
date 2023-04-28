# Terraform Module - Azure - Virtual Network

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This module will create an Azure Virtual Network with subnets using a complex object for configuration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the virtual network. | `string` | n/a | yes |
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address spaces of the virtual network. | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | The BGP Community for this virtual network. | `string` | `null` | no |
| <a name="input_ddos_protection_plan_id"></a> [ddos\_protection\_plan\_id](#input\_ddos\_protection\_plan\_id) | A DDoS Protection plan ID to assign to the virtual network. | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to use with this virtual network. | `list(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_peer_networks"></a> [peer\_networks](#input\_peer\_networks) | Networks to peer to this virtual network. | <pre>list(<br>    object({<br>      name                         = string<br>      id                           = string<br>      allow_virtual_network_access = optional(bool, true)<br>      allow_forwarded_traffic      = optional(bool, true)<br>      allow_gateway_transit        = optional(bool)<br>      use_remote_gateways          = optional(bool)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | Private DNS Zones to link to this virtual network. | <pre>list(<br>    object({<br>      name                 = string<br>      resource_group_name  = string<br>      registration_enabled = optional(bool)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_subnet_nat_gateway_map"></a> [subnet\_nat\_gateway\_map](#input\_subnet\_nat\_gateway\_map) | Mapping of subnet names to NAT Gateway IDs. | `map(string)` | `{}` | no |
| <a name="input_subnet_network_security_group_map"></a> [subnet\_network\_security\_group\_map](#input\_subnet\_network\_security\_group\_map) | Mapping of subnet names to NSG IDs. | `map(string)` | `{}` | no |
| <a name="input_subnet_route_table_map"></a> [subnet\_route\_table\_map](#input\_subnet\_route\_table\_map) | Mapping of subnet names to Route Table IDs. | `map(string)` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to create in this virtual network. | <pre>list(<br>    object({<br>      name                                          = string<br>      prefix                                        = string<br>      service_endpoints                             = optional(list(string))<br>      private_endpoint_network_policies_enabled     = optional(bool)<br>      private_link_service_network_policies_enabled = optional(bool)<br>      delegations = optional(map(<br>        object({<br>          name    = string<br>          actions = list(string)<br>        })<br>      ))<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "name": "default",<br>    "prefix": "10.0.0.0/24"<br>  }<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | Address space of the virtual network. |
| <a name="output_id"></a> [id](#output\_id) | ID of the virtual network. |
| <a name="output_location"></a> [location](#output\_location) | Location of the virtual network. |
| <a name="output_name"></a> [name](#output\_name) | Name of the virtual network. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Subnet configuration. |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone_virtual_network_link.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_network_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_dns_servers.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers) | resource |
| [azurerm_virtual_network_peering.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
