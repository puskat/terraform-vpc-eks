#Cluster creation with logs enabled
resource "aws_eks_cluster" "dev_cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.dev_role.arn
  vpc_config {
    subnet_ids =var.subnet_ids
  }
  enabled_cluster_log_types = var.enabled_cluster_log_types
  depends_on                = [aws_iam_role_policy_attachment.dev_AmazonEKSClusterPolicy]
}

#control plane log group created for monitoring purposes
resource "aws_cloudwatch_log_group" "eks_control_plane_logs" {
  name              = "/aws/eks/${var.cluster_name}/control-plane-logs"
  retention_in_days = 7
}

#node group declaration
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.dev_cluster.name
  node_group_name = "${var.cluster_name}-private-nodes"
  node_role_arn   = aws_iam_role.dev_nodes.arn
  subnet_ids = var.subnet_ids

  lifecycle {
    create_before_destroy = true
    # Allow external changes without Terraform plan difference
    ignore_changes = [scaling_config[0].desired_size]
  }
  capacity_type  = var.capacity_type
  instance_types = ["${var.instance_types}"]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }



  launch_template {
    name    = aws_launch_template.dev.name
    version = aws_launch_template.dev.latest_version
  }

#AWS policies attached to the nodes for basic EKS permissions
  depends_on = [
    aws_iam_role_policy_attachment.dev_nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.dev_nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.dev_nodes_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.dev_nodes_AmazonSSMManagedInstanceCore,
  ]
}

#Launch template defined for the node group.
resource "aws_launch_template" "dev" {
  name_prefix   = var.cluster_name
  image_id      = var.ami_id
  instance_type = var.instance_types
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.ebs_volume_size
      volume_type = var.ebs_volume_type
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = var.cluster_name
    }
  }
}