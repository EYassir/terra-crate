variable "key_name" {
  description = "The name of the keypair"
}
variable "key_value" {
  description = "The value of the keypair"
}
variable "crate_public_subnet_id" {
  description = "The public subnet"
}
variable "crate_vpc_id" {
  description = "The vpc id"
}
variable "tag_name" {
  default = "ey-terraform-bastion"
}
