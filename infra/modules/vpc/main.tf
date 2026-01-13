resource "aws_vpc" "CustomVPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Custom-VPC"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.CustomVPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Public-Subnet1"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id     = aws_vpc.CustomVPC.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "eu-west-2b"


  tags = {
    Name = "Public-Subnet2"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.CustomVPC.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.CustomVPC.id

  route {
    cidr_block = "0.0.0.0/0"
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