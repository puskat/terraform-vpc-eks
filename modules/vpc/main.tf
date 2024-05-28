resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "eks-vpc"
  })

  lifecycle {
    create_before_destroy = true
  }
}

#private subnets are created with correct tags to create the eks cluster 
resource "aws_subnet" "eks_subnet" {
  count = length(var.subnet_cidrs)

  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)
  tags = merge(var.tags, {
    Name = format("eks-subnet-%d", count.index + 1),
    "kubernetes.io/cluster/eks-cluster" = "shared",
    "kubernetes.io/role/internal-elb"   = "1"
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_vpc.eks_vpc]
}

#A route table created to associate with subnets, please note that no nat gateway or internet gateway created to prevent any external communication
resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = merge(var.tags, {
    Name = "eks-route-table"
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_subnet.eks_subnet]
}

resource "aws_route_table_association" "rta_subnet" {
  count = length(aws_subnet.eks_subnet)

  subnet_id      = element(aws_subnet.eks_subnet.*.id, count.index)
  route_table_id = aws_route_table.eks_route_table.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_route_table.eks_route_table]
}


# s3, ecr and acm endpoints are added to the route table to enable communication with these AWS services
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.eks_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.eks_route_table.id]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_route_table.eks_route_table]
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id       = aws_vpc.eks_vpc.id
  service_name = "com.amazonaws.${var.region}.ecr.api"
  route_table_ids = [aws_route_table.eks_route_table.id]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_route_table.eks_route_table]
}

resource "aws_vpc_endpoint" "acm" {
  vpc_id       = aws_vpc.eks_vpc.id
  service_name = "com.amazonaws.${var.region}.acm"
  route_table_ids = [aws_route_table.eks_route_table.id]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_route_table.eks_route_table]
}
