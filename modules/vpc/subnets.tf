resource "aws_subnet" "private_subnets" {
  count             = length(var.vpc_cratedb["private_subnet"])
  vpc_id            = aws_vpc.cratedb_vpc.id
  cidr_block        = var.vpc_cratedb["private_subnet"][count.index]
  availability_zone = "${var.region_name}${var.vpc_cratedb["subnet_az"][count.index]}"
  tags = {
    Name    = "cratedb-${var.vpc_cratedb["name"]}-private-sub-${count.index}"
    Project = "crate-private-cluster"
  }
}

resource "aws_subnet" "public_0" {
  count                   = length(var.vpc_cratedb["public_subnet"])
  vpc_id                  = aws_vpc.cratedb_vpc.id
  cidr_block              = var.vpc_cratedb["public_subnet"][count.index]
  availability_zone       = "${var.region_name}${var.vpc_cratedb["subnet_az"][count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "cratedb-${var.vpc_cratedb["name"]}-public-sub-${count.index}"
  }
}

## Routing

resource "aws_nat_gateway" "crate_ngw" {
  count         = var.vpc_cratedb["has_natg"] ? 1 : 0
  allocation_id = aws_eip.crate_eip_ngw.id
  subnet_id     = aws_subnet.public_0[0].id

  tags = {
    Name = "cratedb-${var.vpc_cratedb["name"]}-nat-gateway"
  }
}

resource "aws_eip" "crate_eip_ngw" {
  vpc = true
}

resource "aws_default_route_table" "r" {
  count                  = var.vpc_cratedb["has_natg"] ? 1 : 0
  default_route_table_id = aws_vpc.cratedb_vpc.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.crate_ngw[0].id
  }

  tags = {
    Name = "crate-db-${var.vpc_cratedb["name"]}-private-route"
  }
}

