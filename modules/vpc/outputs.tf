output "aws_region_az" {
  value = data.aws_availability_zones.available
}

output "vpc" {
  value = aws_vpc.cratedb_vpc
}

output "custom_vpc_public_subnets" {
  value = aws_subnet.public_0
}