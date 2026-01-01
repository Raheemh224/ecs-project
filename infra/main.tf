terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "eu-west-2"  
}


resource "aws_vpc" "CustomVPC" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

tags     = {
  Name   = "PublicRT"
}
  
}

resource "aws_route_table_association" "publicsubnet-route-association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public-route-table.id
}

