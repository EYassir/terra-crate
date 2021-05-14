resource "aws_vpc" "cratedb_vpc" {
  cidr_block           = var.vpc_cratedb["cidr"]
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "crate-${var.vpc_cratedb["name"]}"
  }
}

resource "aws_vpc_dhcp_options" "dns_options" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.cratedb_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_options.id
}

resource "aws_security_group" "cratedb_vpc_default_sg" {
  name        = "cratedb_vpc_${var.vpc_cratedb["name"]}_default_sg"
  description = "Allow ALL inbound traffic"
  vpc_id      = aws_vpc.cratedb_vpc.id

  ingress {
    description = "Allow all Traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cratedb-vpc-default-sg"
  }
}

resource "aws_network_acl" "crate_default_acl" {
  vpc_id = aws_vpc.cratedb_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "crate_${var.vpc_cratedb["name"]}_default_acl"
  }
}
