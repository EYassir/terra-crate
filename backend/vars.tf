variable "region" {
  default = "eu-west-1"
}

variable "remote_backend_bucket_name" {
  default = "eyassir-cratedb-bucket-state"
}

variable "remote_backend_dynamodb_name" {
  default = "eyassir-cratedb-dynamodb-state"
}