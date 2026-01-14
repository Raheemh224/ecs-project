resource "aws_vpc" "ecsapp_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "ecsapp_vpc"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.ecsapp_vpc.id
  cidr_block = var.public_subnet1_cidr
  availability_zone = var.availability_zone1

  tags = {
    Name = "Public-Subnet1"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id     = aws_vpc.ecsapp_vpc.id
  cidr_block = var.public_subnet2_cidr
  availability_zone = var.availability_zone2


  tags = {
    Name = "Public-Subnet2"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ecsapp_vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ecsapp_vpc.id

  route {
    cidr_block = var.route_table
    gateway_id = aws_internet_gateway.gw.id
  }

tags     = {
  Name   = "PublicRT"
}
  
}

resource "aws_route_table_association" "public-route-association" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public-route-association2" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.public_route_table.id
}