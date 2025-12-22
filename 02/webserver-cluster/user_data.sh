#!/bin/bash
dnf install -y httpd
echo "MY ALB Web Page" > /var/www/html/index.html
systemctl restart httpd && systemctl enable httpd