module "vpc" {
  source = "./modules/vpc"

  cidr_block         = var.cidr_block
  subnet_cidrs       = var.subnet_cidrs
  availability_zones = var.availability_zones
  region             = var.region
  tags = var.tags
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}

output "route_table_id" {
  value = module.vpc.route_table_id
}

module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  instance_types = var.instance_types
  desired_size = var.desired_size
  min_size = var.min_size
  max_size = var.max_size
  ami_id = var.ami_id
  subnet_ids = module.vpc.subnet_ids
}

