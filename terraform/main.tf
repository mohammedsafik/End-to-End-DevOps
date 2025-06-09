provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "k8s-vpc" }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "k8s-subnet" }
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "mykeypair" {
  type = string
}

resource "aws_instance" "master" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  key_name      = var.mykeypair
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  user_data = file("../scripts/setup-k8s-master.sh")
  tags = { Name = "k8s-master" }
}

resource "aws_instance" "worker" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  key_name      = var.mykeypair
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  user_data = file("../scripts/setup-k8s-worker.sh")
  tags = { Name = "k8s-worker" }
}
