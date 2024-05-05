provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "webserver1" {
  ami                    = "ami-07caf09b362be10b8"
  instance_type          = var.instance_type
  tags = {
    Name        = "webserver"
    Description = " An amazon server"
  }
  root_block_device {
    volume_type = var.volume_type  # General Purpose SSD
    volume_size = 20     # Size in GB
    encrypted   = true   # Enable encryption
  }
  key_name = aws_key_pair.mykey.key_name
  provisioner "remote-exec" {
    inline = ["touch first.txt"]
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("./${var.key_name}")
}

}
output "instance_ip_addr" {
  value = aws_instance.webserver1.public_ip
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_security_group" "teraform_sg1" {
  vpc_id = "${aws_vpc.ec2-vpc.id}"
  name = "teraform_sg1"
  ingress {      
      from_port   = var.ingress_port
      to_port     = var.ingress_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
}
resource "aws_vpc" "ec2-vpc" {
    cidr_block = var.cidr_block_vpc
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    instance_tenancy = "default"

    tags =  {
        Name = "ec2-vpc"
    }
}


resource "aws_subnet" "ec2-subnet-public-1" {
    vpc_id = "${aws_vpc.ec2-vpc.id}"
    cidr_block = var.cidr_block_subnet
    availability_zone = var.availability_zone
    tags =  {
        Name = "ec2-subnet-public-1"
    }
}


resource "aws_internet_gateway" "ec2-igw" {
    vpc_id = "${aws_vpc.ec2-vpc.id}"
    tags =  {
        Name = "ec2-igw"
    }
}


resource "aws_route_table" "ec2-public-crt" {
    vpc_id = "${aws_vpc.ec2-vpc.id}"

    route {
        //associated subnet can reach everywhere
        cidr_block = var.cidr_block_rt
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.ec2-igw.id}"
    }

    tags = {
        Name = "ec2-public-crt"
    }
}

resource "aws_route_table_association" "ec2-crta-public-subnet-1"{
    subnet_id = "${aws_subnet.ec2-subnet-public-1.id}"
    route_table_id = "${aws_route_table.ec2-public-crt.id}"
}
resource "aws_key_pair" "mykey" {
  key_name   = "first_key"
  public_key = file("${var.key_name}.pub")
}
