resource "aws_internet_gateway" "crate_ig" {
  count  = var.vpc_cratedb["has_ig"] ? 1 : 0
  vpc_id = aws_vpc.cratedb_vpc.id

  tags = {
    Name = "crate-${var.vpc_cratedb["name"]}-vpc-ig"
  }
}

resource "aws_route_table" "crate_public_route" {
  count  = var.vpc_cratedb["has_ig"] ? 1 : 0
  vpc_id = aws_vpc.cratedb_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.crate_ig[count.index].id
  }

  tags = {
    Name = "crate-${var.vpc_cratedb["name"]}-public-route"
  }
}

resource "aws_route_table_association" "crate_a" {
  count          = length(var.vpc_cratedb["public_subnet"])
  subnet_id      = aws_subnet.public_0[count.index].id
  route_table_id = aws_route_table.crate_public_route[count.index - count.index].id
}
