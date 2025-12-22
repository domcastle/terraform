output "dbaddress" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.this.address
}
output "dbport" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.this.port
}
output "dbname" {
  description = "The name of the database"
  value       = aws_db_instance.this.db_name
}