# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web-server" {
  ami                         = "ami-0e35ddab05955cf57"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.web-server-key-pair.key_name
  vpc_security_group_ids      = [aws_security_group.web-server-sg.id]
  user_data                   = <<-EOF
    #!/usr/bin/env bash
    echo "hello world" > index.html
    nohup busybox httpd -f -p 8080 &
  EOF
  user_data_replace_on_change = true
  tags = {
    Name = "ssh-machine"
  }
}

resource "aws_security_group" "web-server-sg" {
  name = "web-server-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "web-server-key-pair" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2bl3yHCcGK2dvde0CYmWmcYWiBSju3OuVyj4O9afJp manujkarki101@gmail.com"
}

output "web-server-ip" {
  value       = aws_instance.web-server.public_ip
  description = "IP address of web-server"
}
