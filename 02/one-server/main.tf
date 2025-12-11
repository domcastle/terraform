##############################
# 1. provider
# 2. EC2 Instance
##############################
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

# 1. provider 
provider "aws" {
  region = "us-east-2"
}

# 2. resource - EC2 create

resource "aws_instance" "example" {
  ami                    = "ami-00e428798e77d38d9"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    echo "Hello World" > index.html
    nohup busybox httpd -f -p 8080 &
    EOF

  tags = {
    Name = "terraform example"
  }
}
resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_8080"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_http" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

