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

# mutliple subnets for db to meet high availability requirements
resource "aws_subnet" "paperless-subnet-db-a" {
  vpc_id                  = aws_vpc.paperless.id
  cidr_block              = "10.0.2.0/28"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "paperless-db-subnet-a"
  }
}
resource "aws_subnet" "paperless-subnet-db-b" {
  vpc_id                  = aws_vpc.paperless.id
  cidr_block              = "10.0.3.0/28"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "paperless-db-subnet-b"
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

resource "aws_db_subnet_group" "paperless-db" {
  name       = "paperless"
  subnet_ids = [aws_subnet.paperless-subnet-db-a.id, aws_subnet.paperless-subnet-db-b.id]
  tags = {
    Name = "paperless-db"
  }
}

resource "aws_security_group" "paperless-db-sg" {
  name   = "paperless-db-sg"
  vpc_id = aws_vpc.paperless.id
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # we give access to paperless security group so that paperless ec2 instance can access the database
    security_groups = [aws_security_group.paperless-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "paperless-db-sg"
  }
}

resource "aws_db_instance" "paperless-db" {
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "paperless"
  username                = "paperless"
  password                = "paperless"
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 0
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.paperless-db.name
  vpc_security_group_ids  = [aws_security_group.paperless-db-sg.id]
  tags = {
    Name = "paperless-db"
  }

}


output "paperless-ip" {
  value       = aws_instance.paperless.public_ip
  description = "IP address of web-server"
}

output "rds_endpoint" {
  value = aws_db_instance.paperless-db.endpoint
}
