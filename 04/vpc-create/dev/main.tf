provider "aws" {
  region = "us-east-2"
}

module "my_vpc" {
  source = "../modules/vpc"
  vpc_cidr    = "192.168.10.0/24"
  subnet_cidr = "192.168.10.0/25"

}
