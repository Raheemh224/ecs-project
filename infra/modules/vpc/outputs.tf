output "vpc_id" {
  value = aws_vpc.ecsapp_vpc.id
}

output "public_subnet1_id" {
  value = aws_subnet.PublicSubnet1.id
}

output "public_subnet2_id" {
  value = aws_subnet.PublicSubnet2.id
}