data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-*"]
  }
}

variable "vpc_id" {
  description = "the id of vpc to work on"
}

variable "key_name" {
  description = "The key pair that will be used"
}
variable "key_value" {
  description = "The key pair that will be used"
}

variable "dashboard_port" {
  default = 4200
}

variable "node_port" {
  default = 4300
}

data "aws_vpc" "crate_vpc" {
  id = var.vpc_id
}

#subnet prive
data "aws_subnet_ids" "crate_vpc_subnets_ids" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Project"
    values = ["crate-private-cluster"]
  }
}


resource "random_string" "random" {
  length  = 8
  special = false
  number  = false
  upper   = false
}
