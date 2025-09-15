provider "aws" {
    region = "us-east-1"
}

#VPC

resource "aws_vpc" "teste-tf-gui" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "teste-tf-gui-vpc"
    }
}

#Subnet

resource "aws_subnet" "public-teste-tf-gui" {
    vpc_id = aws_vpc.teste-tf-gui.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    
    tags = {
        Name = "public-subnet"
    }
}

#Internet Gateway

resource "aws_internet_gateway" "igw-teste-tf-gui" {
    vpc_id = aws_vpc.teste-tf-gui.id

    tags = {
        Name = "vpc-gw"
    }
}

#Route table
resource "aws_route_table" "rt-public-teste-tf-gui" {
    vpc_id = aws_vpc.teste-tf-gui.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw-teste-tf-gui.id
    }
    
    tags = {
        Name = "route-public"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public-teste-tf-gui.id
    route_table_id = aws_route_table.rt-public-teste-tf-gui.id
}

#Security Group
resource "aws_security_group" "SG-teste-tf-gui"{
    name = "SG-teste-tf-gui"
    description = "SG-teste-tf-gui"
    vpc_id = aws_vpc.teste-tf-gui.id

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SG-teste-tf-gui"
    }
}

# EC2 

resource "aws_instance" "teste-tf-gui-ec2" {
    ami = "ami-0b09ffb6d8b58ca91"
    instance_type = "t2.micro"

    subnet_id = aws_subnet.public-teste-tf-gui.id
    vpc_security_group_ids = [aws_security_group.SG-teste-tf-gui.id]
    associate_public_ip_address = true

    root_block_device {
        volume_size = 8
        volume_type = "gp3"
        delete_on_termination = true
    }

    tags = {
        Name = "teste-tf-gui-ec2"
    }
}