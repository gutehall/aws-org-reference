output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  value = aws_ec2_transit_gateway.this.arn
}

output "egress_vpc_id" {
  value = aws_vpc.egress.id
}

output "nat_gateway_id" {
  description = "Single centralized NAT in the network account. No per-VPC NAT."
  value       = aws_nat_gateway.egress.id
}

output "ram_resource_share_arn" {
  value = aws_ram_resource_share.tgw.arn
}
