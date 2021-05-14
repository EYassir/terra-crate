
variable "vpc_id" {
  description = "the id of vpc to work on"
  default     = ""
}

data "aws_vpc" "crate_vpc" {
  id = var.vpc_id
}

#private subnets
data "aws_subnet_ids" "private_crate_vpc_subnets" {
  vpc_id = data.aws_vpc.crate_vpc.id
  filter {
    name   = "tag:Project"
    values = ["crate-private-cluster"]
  }
}

variable "external_port" {
  description = "the port number of the web"
  type        = number
  default     = 80
}

variable "target_group" {
  description = "arn of target"
  default     = ""
}
