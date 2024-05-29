
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}

output "route_table_id" {
  value = module.vpc.route_table_id
}

output "route_table_association_ids" {
  value = module.vpc.route_table_association_ids
}

output "s3_vpc_endpoint_id" {
  value = module.vpc.s3_vpc_endpoint_id
}

output "ecr_vpc_endpoint_id" {
  value = module.vpc.ecr_vpc_endpoint_id
}

output "acm_vpc_endpoint_id" {
  value = module.vpc.acm_vpc_endpoint_id
  
}