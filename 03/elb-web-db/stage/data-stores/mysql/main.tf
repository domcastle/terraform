################################
# 1. provider 설정
# 2. DB(MySQL) 생성
################################
provider "aws" {
  region = "us-east-2"
}

# 2. DB(MySQL) 생성
# * username/password
# * DB name
resource "aws_db_instance" "mydb" {
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.c6gd.medium"
  username             = "${var.dbuser}"
  password             = "${var.dbpassword}"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}