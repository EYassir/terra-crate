variable "region" {
  default = "eu-west-1"
}

#START : VPC PARAMS
variable "vpc_cratedb" {
  description = "The crateDB VPC"
  default = {
    "name" : "crate-db"
    "cidr" : "10.0.0.0/16",
    "has_ig" : true,
    "private_subnet" : ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"],
    "public_subnet" : ["10.0.4.0/24"],
    "subnet_az" : ["a", "b", "c"],
    "has_natg" : true
  }
}
#END : END VPC PARAMS

#START :  ASG PARAMS
variable "key_name" {
  description = "The key pair that will be used"
  default     = "cratedb-keypair"
}
variable "key_value" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoNQFyr9ixEPl2ppLFMxo4C7o02HEtpz6HWZwsY2p0dtiezYSUpYpnevnR8SAgS3ISMTQ6CTn57LKoCV3AaPAF5fkA4D1X4UuKCYEQn1es6yqD1N5tgqBJqblKgu2LjxNrC9G4bZebgZLrgsqmnxnKfwLj5x2jRTKN5dbdumdjeXhdhSAbCm3JdCGpJJKkFBLKt52HeVKTQp3Thii6qK9BW/k42CiB458rYgyNHN5e/6cIBk0c0HVNfeR9zaFBsL2N8Oah5azNih1/T5Jj8ZLduCIMDA6AD+a/SxlmfTiyHRatqNJ6pj1I4FIJdu5r+OmE3QNZH99kgKovR+boTSJeJLS5Sy5kOiTv8aB2k3ZTzvm8DBeZG6vX3WPj1jTnQM2607AdxZlJNnTnNcUm6h2StRO52FPTGnbvFWo6G9kfTMhfGjarjHgElU1TsIdPh/fpn5CYhvJLuwLSwsfwbgmYn56Ksj6bnTfBo4UlS01aU9WTZIHRdkihZV7d8G2jpZ8= yassir@ubuntu"
}

variable "app_port" {
  description = "the port number of the web"
  type        = number
  default     = 4200
}

#END : ASG PARAMS
