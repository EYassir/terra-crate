variable "region_name" {
  description = "region name"
}

variable "vpc_cratedb" {
  description = "The crateDB VPC"
}

data "aws_availability_zones" "available" {
  state = "available"
}


