variable "dbuser" {
  description = "DB username(ex:dbuser)"
  type = string
  sensitive = true
}
variable "dbpassword" {
  description = "DB password"
  type = string
  sensitive = true
}