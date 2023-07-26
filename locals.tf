locals {
  subnet_network_security_group_map = { for k, v in var.subnets : k => v.network_security_group_id if v.associate_nsg }
  subnet_route_table_map            = { for k, v in var.subnets : k => v.route_table_id if v.associate_rt }
  subnet_nat_gateway_map            = { for k, v in var.subnets : k => v.nat_gateway_id if v.associate_ngw }
}