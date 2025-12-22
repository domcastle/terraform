output "myalb_dnsname" {
  description = "The DNS name of the ALB"
  value       = aws_lb.myalb.dns_name
}

output "myalb_url" {
  description = "My ALB DNS URL"
  value      = "http://${aws_lb.myalb.dns_name}"
}