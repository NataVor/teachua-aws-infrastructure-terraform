variable "region" {}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {}
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "azs" {
  type = list(string)
}
