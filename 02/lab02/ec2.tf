##################################
# 1. provider
# 2. EC2
# - SG
# - EC2(keypair)
##################################


# Provider 설정
provider "aws" {
  region = "us-east-2"
}

# EC2 인스턴스 AMI ID를 위한 Data Source 조회
# * Amazon Linux 2023 AMI
data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.20251208.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

# EC2 생성
data "aws_vpc" "default" {
  default = true
}
# SG 설정 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group


resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow TLS inbound SSH traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "mysg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}
# keypair 생성 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/mykeypair.pub")
}

# EC2 인스턴스 생성 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#key_name-1
resource "aws_instance" "myInstance" {
  ami           = data.aws_ami.amazon2023.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "mykeypair"

  tags = {
    Name = "myInstance"
  }
}

output "ami_id" {
    value = aws_instance.myInstance.ami
    description = "Amazone Linux 2023 AMI ID"
}

output "myInstanceIP" {
    value = aws_instance.myInstance.public_ip
    description = "aws_instance myInstance Public IP"
}