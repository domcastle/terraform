##############################
# 1. SG 생성
# 2. EC2 생성
##############################

##############################
# 1. SG 생성
##############################
# SG create
# * ingress: 80/tcp, 443/tcp
# * egress: all
#
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow TLS inbound 80/tcp, 443/tcp traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mySG_2" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "mySG_80" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "mySG_443" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "mySG_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

##############################
# 2. EC2 생성
##############################
# * mySubSN에 생성
# EC2 create
# * user_data(80/tcp, 443/tcp listen) => user_data change->EC2 recreate
# * SG 연결
# AMI: amazon linux 2023 ami
# create a key pair
# ssh-keygen -t rsa -N "" -f ~/.ssh/mykeypair
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/mykeypair.pub")
}

resource "aws_instance" "myEC2" {
  ami                    = "ami-00e428798e77d38d9"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.myPubSN.id
  vpc_security_group_ids = [aws_security_group.mySG.id]
  key_name               = "mykeypair"

  user_data_replace_on_change = true
  user_data                   = <<-EOF
        #!/bin/bash
        dnf install -y httpd mod_ssl
        echo "My Web Server Test Page" > /var/www/html/index.html
        systemctl enable --now httpd
        EOF

  tags = {
    Name = "myEC2"
  }
}
