# 1. NAT Gateway 생성
resource "aws_eip" "myEIP" {
  domain = "vpc"
}
resource "aws_nat_gateway" "myNAT-GW" {
  allocation_id = aws_eip.myEIP.id
  subnet_id     = aws_subnet.myPubSN.id

  tags = {
    Name = "myNAT-GW"
  }
  depends_on = [aws_internet_gateway.myIGW]
}
# 2. private Subnet 생성 및 라우팅 설정
resource "aws_subnet" "myPriSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "myPriSN"
  }
}

# 3. Private Route Table 생성 및 연결
# Private-RT 생성
# * NAT-GW를 통한 default route 설정
resource "aws_route_table" "myPriRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNAT-GW.id
  }

  tags = {
    Name = "myPriRT"
  }

}
resource "aws_route_table_association" "myPriRTassoc" {
  subnet_id      = aws_subnet.myPriSN.id
  route_table_id = aws_route_table.myPriRT.id
}

# 4. Security Group 생성 
resource "aws_security_group" "mySG2" {
  name        = "mySG2"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mySG2_80" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "mySG2_22" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "mySG2_443" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "mySG2_all" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 5. EC2 생성
# EC2 create
# Private Subnet에 생성
# * user_data(WEB server) => user_data change->EC2 recreate
# * mySG2 연결
# * mykeypair 키 사용
# 
# create a key pair
# ssh-keygen -t rsa -N "" -f ~/.ssh/mykeypair
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair

# EC2 instance
resource "aws_instance" "myEC2-2" {
  ami                    = "ami-00e428798e77d38d9"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.myPriSN.id
  key_name               = "mykeypair"
  vpc_security_group_ids = [aws_security_group.mySG2.id]

  user_data_replace_on_change = true
  user_data                   = <<-EOF
        #!/bin/bash
        dnf install -y httpd mod_ssl
        echo "My Web Server 2 Test Page" > /var/www/html/index.html
        systemctl enable --now httpd
        EOF

  tags = {
    Name = "myEC2-2"
  }
}