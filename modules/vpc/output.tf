output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.eks_vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = aws_subnet.eks_subnet[*].id
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = aws_route_table.eks_route_table.id
}
