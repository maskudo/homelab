# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"

}


resource "aws_vpc" "paperless" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "paperless"
  }
}

resource "aws_subnet" "paperless-subnet" {
  vpc_id                  = aws_vpc.paperless.id
  cidr_block              = "10.0.1.0/28"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "paperless-subnet"
  }
}

resource "aws_internet_gateway" "paperless-igw" {
  vpc_id = aws_vpc.paperless.id
  tags = {
    Name = "paperless-igw"
  }
}

resource "aws_route_table" "paperless-rt" {
  vpc_id = aws_vpc.paperless.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.paperless-igw.id
  }
}

resource "aws_route_table_association" "paperless-rta" {
  subnet_id      = aws_subnet.paperless-subnet.id
  route_table_id = aws_route_table.paperless-rt.id
}

resource "aws_security_group" "paperless-sg" {
  vpc_id = aws_vpc.paperless.id
  name   = "paperless-sg"
  ingress {
    from_port   = 8000
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "paperless-sg"
  }
}


resource "aws_instance" "paperless" {
  ami                    = "ami-0e35ddab05955cf57"
  subnet_id              = aws_subnet.paperless-subnet.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.web-server-key-pair.key_name
  vpc_security_group_ids = [aws_security_group.paperless-sg.id]
  tags = {
    Name = "paperless-machine"
  }
}

resource "aws_key_pair" "web-server-key-pair" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2bl3yHCcGK2dvde0CYmWmcYWiBSju3OuVyj4O9afJp manujkarki101@gmail.com"
}

output "paperless-ip" {
  value       = aws_instance.paperless.public_ip
  description = "IP address of web-server"
}
