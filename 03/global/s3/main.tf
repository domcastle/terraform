################################
# 1. S3 Bucket 생성
# 2. DynamoDB 테이블 생성
################################
# resource "aws_s3_bucket" "mytfstate" {
#   bucket = "mypsw-7979"

#   tags = {
#     Name        = "mypsw-7979"
#   }
# }

resource "aws_dynamodb_table" "my_tflocks" {
  name           = "my_tflocks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}