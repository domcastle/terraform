# [출력 변수]
output "public_ip" {
  value       = aws_instance.myinstance.public_ip
  description = "The public IP address of the web server"
}

output "public_dns_name" {
    value = aws_instance.myinstance.public_dns
    description = "The public DNS name of the web server"
}