terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
  backend "s3" {
    bucket = "mypsw-7979"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "my_tflocks"
  }
}
provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "myEC2" {
  ami           = "ami-00e428798e77d38d9"
  instance_type = "t3.micro"

  tags = {
    Name = "myEC2"
  }
}