variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
 description = "Public Subnet CIDR values"
 default     = "10.0.4.0/24"
}
 
variable "private_subnet_cidrs" {
 # type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b"]
}