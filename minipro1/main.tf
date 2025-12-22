####################################
# 1. 인프라 구성
# * VPC 생성
# * IGW 생성 및 연결
# * Public Subnet 생성
# * Route Table 생성 및 라우팅 설정
# 2. EC2 생성
# *  Security Group 생성 (22, 80 포트 오픈)
# *  key pair 생성
# *  EC2 생성
#   - User_Data(docker CMD)
# 3. 사용자 연결
####################################



####################################
# 1. 인프라 구성
####################################
# * VPC 생성
# * DNS Hostnames 활성화
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "myVPC"
  }
}
# * IGW 생성 및 연결
####################################
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# * Public Subnet 생성
# * 공인 ip 자동 할당
####################################
resource "aws_subnet" "myPubSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSN"
  }
}

# * Route Table 생성 및 라우팅 설정
####################################
# * myIGW -> default route 설정
# * myPubSN에 연결
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}

resource "aws_route_table_association" "myPubRTA" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}
# 2. EC2 생성
####################################
# *  Security Group 생성 (22, 80 포트 오픈)
# *  ingress/egress 설정
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow TLS all inbound traffic and outbound all traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mySG_in_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0" 
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "mySG_out_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

####################################
# *  key pair 생성
####################################
# * SSH-keygen 으로 생성한 공개키 등록
# * ssh-keygen -t rsa -N "" -f ~/.ssh/mykeypair
#  -> ~/.ssh/mykeypair.pub
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/mykeypair.pub")
}
# *  EC2 생성
####################################
# * 새로 생성한 pubsubnet에 생성
# * security group 연결
# * key pair 연결
# * ami: Ubuntu 24.04 LTS
# * User Data: docker 설치 및 컨테이너 실행
#   - User_Data(docker CMD)
####################################
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "myEC2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.myPubSN.id
  vpc_security_group_ids = [aws_security_group.mySG.id]
  key_name = aws_key_pair.mykeypair.key_name

  user_data_base64 = filebase64("user_data.sh")
  user_data_replace_on_change = true

  provisioner "local-exec" {
    command = templatefile("make_config.sh",{
      hostname = self.public_ip,
      user = "ubuntu",
      identifyfile = "~/.ssh/mykeypair"
    })
    interpreter = ["bash", "-c"]
  }
  
  tags = {
    Name = "myEC2"
  }
}
# 3. 사용자 연결
####################################
