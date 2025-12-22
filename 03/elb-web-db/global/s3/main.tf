provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "mytfstate" {
  bucket = "mypsw-7979"

  tags = {
    Name        = "My bucket"
  }
}

resource "aws_dynamodb_table" "mylocktable" {
  name           = "mylocktable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "mylocktable"
  }
}