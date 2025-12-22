# output "mybucket_arn" {
#   value = aws_s3_bucket.mytfstate.arn
# }
output "name" {
  value = aws_dynamodb_table.my_tflocks.name
}