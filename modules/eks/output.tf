output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.dev_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = aws_eks_cluster.dev_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.dev_cluster.certificate_authority[0].data
}

output "cluster_oidc_issuer" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.dev_cluster.identity[0].oidc[0].issuer
}

output "node_group_name" {
  description = "The name of the node group"
  value       = aws_eks_node_group.private-nodes.node_group_name
}

output "node_group_arn" {
  description = "The ARN of the node group"
  value       = aws_eks_node_group.private-nodes.arn
}

output "node_group_instance_types" {
  description = "The instance types of the node group"
  value       = aws_eks_node_group.private-nodes.instance_types
}

output "node_group_desired_size" {
  description = "The desired size of the node group"
  value       = aws_eks_node_group.private-nodes.scaling_config[0].desired_size
}

output "node_group_min_size" {
  description = "The minimum size of the node group"
  value       = aws_eks_node_group.private-nodes.scaling_config[0].min_size
}

output "node_group_max_size" {
  description = "The maximum size of the node group"
  value       = aws_eks_node_group.private-nodes.scaling_config[0].max_size
}

output "launch_template_id" {
  description = "The ID of the launch template used for the node group"
  value       = aws_launch_template.dev.id
}

output "launch_template_name" {
  description = "The name of the launch template used for the node group"
  value       = aws_launch_template.dev.name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for the EKS control plane"
  value       = aws_cloudwatch_log_group.eks_control_plane_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the EKS control plane"
  value       = aws_cloudwatch_log_group.eks_control_plane_logs.arn
}

output "iam_role_eks_cluster" {
  description = "The IAM role for the EKS cluster"
  value       = aws_iam_role.dev_role.arn
}

output "iam_role_node_group" {
  description = "The IAM role for the EKS node group"
  value       = aws_iam_role.dev_nodes.arn
}

output "iam_role_oidc" {
  description = "The IAM role for OIDC"
  value       = aws_iam_role.dev_oidc.arn
}

output "iam_role_autoscaler" {
  description = "The IAM role for the cluster autoscaler"
  value       = aws_iam_role.dev_eks_cluster_autoscaler.arn
}

output "iam_role_csi_driver" {
  description = "The IAM role for the EBS CSI driver"
  value       = aws_iam_role.eks_ebs_csi_driver.arn
}

output "iam_role_load_balancer_controller" {
  description = "The IAM role for the AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

