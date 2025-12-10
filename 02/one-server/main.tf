provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-00e428798e77d38d9"
  instance_type = "t2.micro"

  user_data_replace_on_change = true
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World" > index.html
    nohup busybox httpd -f -p 8080 &
    EOF

  tags = {
    Name = "terraform example"
  }
}