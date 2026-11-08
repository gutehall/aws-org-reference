# Apply only when the client list includes a network account.
# Cost (TGW + single NAT) must be agreed before this apply.
# Pass aws.network from the stack (assume role into the network account).

locals {
  tags = merge(
    {
      Project   = "aws-org-reference"
      Component = "network"
    },
    var.tags,
  )

  az_count = length(var.availability_zones)
}

resource "aws_vpc" "egress" {
  provider = aws.network

  cidr_block           = var.egress_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.tags, { Name = "${var.name_prefix}-egress" })
}

resource "aws_subnet" "egress_public" {
  provider = aws.network
  count    = local.az_count

  vpc_id                  = aws_vpc.egress.id
  cidr_block              = cidrsubnet(var.egress_vpc_cidr, 4, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { Name = "${var.name_prefix}-egress-public-${count.index}" })
}

resource "aws_internet_gateway" "egress" {
  provider = aws.network
  vpc_id   = aws_vpc.egress.id
  tags     = local.tags
}

resource "aws_eip" "nat" {
  provider = aws.network
  domain   = "vpc"
  tags     = local.tags
}

resource "aws_nat_gateway" "egress" {
  provider = aws.network

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.egress_public[0].id
  tags          = merge(local.tags, { Name = "${var.name_prefix}-egress-nat" })

  depends_on = [aws_internet_gateway.egress]
}

resource "aws_subnet" "egress_private" {
  provider = aws.network
  count    = local.az_count

  vpc_id            = aws_vpc.egress.id
  cidr_block        = cidrsubnet(var.egress_vpc_cidr, 4, count.index + local.az_count)
  availability_zone = var.availability_zones[count.index]
  tags              = merge(local.tags, { Name = "${var.name_prefix}-egress-private-${count.index}" })
}

resource "aws_route_table" "egress_public" {
  provider = aws.network
  vpc_id   = aws_vpc.egress.id
  tags     = local.tags

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.egress.id
  }
}

resource "aws_route_table_association" "egress_public" {
  provider = aws.network
  count    = local.az_count

  subnet_id      = aws_subnet.egress_public[count.index].id
  route_table_id = aws_route_table.egress_public.id
}

resource "aws_route_table" "egress_private" {
  provider = aws.network
  vpc_id   = aws_vpc.egress.id
  tags     = local.tags

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.egress.id
  }
}

resource "aws_route_table_association" "egress_private" {
  provider = aws.network
  count    = local.az_count

  subnet_id      = aws_subnet.egress_private[count.index].id
  route_table_id = aws_route_table.egress_private.id
}

resource "aws_ec2_transit_gateway" "this" {
  provider = aws.network

  description                     = "${var.name_prefix} shared TGW"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags                            = merge(local.tags, { Name = "${var.name_prefix}-tgw" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  provider = aws.network

  subnet_ids         = aws_subnet.egress_private[*].id
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = aws_vpc.egress.id
  tags               = local.tags
}

resource "aws_ram_resource_share" "tgw" {
  provider = aws.network

  name                      = "${var.name_prefix}-tgw"
  allow_external_principals = false
  tags                      = local.tags
}

resource "aws_ram_resource_association" "tgw" {
  provider = aws.network

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

resource "aws_ram_principal_association" "workloads" {
  provider = aws.network
  for_each = toset(var.workload_account_ids)

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw.arn
}
