output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "internet_gateway_id" {
  description = "Internet gateway ID"
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}
