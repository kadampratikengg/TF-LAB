terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.77.0"
    }
    
  } 
}
provider "aws" {
  region = "us-east-1"  
}

#vpc
resource "aws_vpc" "main" {
  cidr_block           = "172.16.0.0/16"
  tags = {
    Name = "vpc-01"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-route-table"
  }
}

# Internet Gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate the Public Subnet with the Public Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "nat-gateway"
  }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private-route-table"
  }
}

# Add a Route for the NAT Gateway in the Private Route Table
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

# Associate the Private Subnet with the Private Route Table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Launch an EC2 Instance in the Private Subnet
resource "aws_instance" "private_ec2" {
  ami           = "ami-0c02fb55956c7d316"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  tags = {
    Name = "private-ec2-instance"
  }
}
