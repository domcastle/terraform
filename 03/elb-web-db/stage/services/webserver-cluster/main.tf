#########################################
# 1. provider
# * terraform
# * provider
# * terraform_remote_state
# 2. ASG
# * default vpc
# * default subnets
# * SG
# * launch template
# * ASG
# 3. ALB
# * TG
# * SG
# * ALB 
# * ALB listener
# * ALB listener rule
#########################################

#########################################
# 1. provider
#########################################
# * terraform
# * provider
# * terraform_remote_state
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "terraform_remote_state" "myremotestate" {
  backend = "s3"

  config = {
    bucket        = "mypsw-7979"
    key           = "global/s3/terraform.tfstate"
    region        = "us-east-2"

    encrypt       = true
    use_lockfile  = true
  }
}

#########################################
# 2. ASG
#########################################
# * default vpc
# * default subnets
# * SG
# * launch template
# * ASG

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Default Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# SG - LT에 사용할 SG 정의
# * 80/tcp 
resource "aws_security_group" "myLTSG" {
  name        = "myLTSG"
  description = "Allow TLS inbound 80/tcp traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myLTSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myLTSG-in-80" {
  security_group_id = aws_security_group.myLTSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "myLTSG-out-all" {
  security_group_id = aws_security_group.myLTSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# * launch template
#   - aws_ami data source
data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.*.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_launch_template" "myLT" {
  name = "myLT"
  image_id = data.aws_ami.amazon2023.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.myLTSG.id]
  user_data = base64encode(templatefile("./user_data.sh",{
    dbaddress = data.terraform_remote_state.myremotestate.outputs.dbaddress,
    dbport = data.terraform_remote_state.myremotestate.outputs.dbport,
    dbname = data.terraform_remote_state.myremotestate.outputs.dbname
  }))
}
