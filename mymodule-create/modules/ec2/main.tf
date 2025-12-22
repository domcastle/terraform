resource "aws_security_group" "SG" {
  name        = "SG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "SG_80" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "SG_all" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}


data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.*.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazonlinux.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.SG.id]

  tags = {
    Name = "HelloWorld"
  }
}