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

output "route_table_association_ids" {
  description = "The IDs of the route table associations"
  value       = aws_route_table_association.rta_subnet[*].id
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for S3"
  value       = aws_vpc_endpoint.s3.id
}

output "ecr_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for ECR"
  value       = aws_vpc_endpoint.ecr.id
}

output "acm_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for ACM"
  value       = aws_vpc_endpoint.acm.id
}

output "vpc_endpoint_s3_arn" {
  description = "The ARN of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.arn
}

output "vpc_endpoint_ecr_arn" {
  description = "The ARN of the ECR VPC endpoint"
  value       = aws_vpc_endpoint.ecr.arn
}

output "vpc_endpoint_acm_arn" {
  description = "The ARN of the ACM VPC endpoint"
  value       = aws_vpc_endpoint.acm.arn
}
