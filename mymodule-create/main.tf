# VPC create 
# IGW create & VPC attach
# Public Subnet create
# Route Table create & Public Route

provider "aws" {
  region = "us-east-2"
}

module "my_vpc" {
  source = "./modules/net"
}

module "my_ec2" {
  source = "./modules/ec2"
  vpc_id = module.my_vpc.vpc_id
}