provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "eyassir-cratedb-bucket-state"
    key            = "crate-db-cluster/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "eyassir-cratedb-dynamodb-state"
    encrypt        = true
  }
}

module "vpc_cratedb_module" {
  source      = "./modules/vpc"
  vpc_cratedb = var.vpc_cratedb
  region_name = var.region
}

module "bastion_module" {
  source                 = "./modules/bastion"
  crate_public_subnet_id = module.vpc_cratedb_module.custom_vpc_public_subnets[0].id
  crate_vpc_id           = module.vpc_cratedb_module.vpc.id
  region_name            = var.region
  key_name               = var.key_name
  key_value              = var.key_value
  tag_name               = "crate-bastion"
}


module "crate_asg" {
  source         = "./modules/asg"
  key_name       = "crate-keypair"
  key_value      = var.key_value
  vpc_id         = module.vpc_cratedb_module.vpc.id
  dashboard_port = var.app_port
}

module "crate_internal_lb" {
  source        = "./modules/lb"
  vpc_id        = module.vpc_cratedb_module.vpc.id
  external_port = 80
  target_group  = module.crate_asg.asg_crate_taget_group
}
