#specific IAM role created for EKS cluster.
resource "aws_iam_role" "dev_role" {
  name               = "${var.cluster_name}_role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# allow eks control plane logging
resource "aws_iam_policy" "dev_cluster_control_plane_logs" {
  name   = var.dev_cluster_control_plane_logs_policy_name
    policy = jsonencode({
    Statement = [{
      Action = [ "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Effect = "Allow"
      Resource = "arn:aws:logs:*:*:*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "dev_cluster_control_plane_logs" {
  policy_arn = aws_iam_policy.dev_cluster_control_plane_logs.arn
  role       = aws_iam_role.dev_role.name
}
resource "aws_iam_role_policy_attachment" "dev_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.dev_role.name
}

#AWS IAM role for node group.
resource "aws_iam_role" "dev_nodes" {
  name = "eks-node-group-nodes"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

#AWS EKS policies are attached to the dev_node role
resource "aws_iam_role_policy_attachment" "dev_nodes_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.dev_nodes.name
}
resource "aws_iam_role_policy_attachment" "dev_nodes_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.dev_nodes.name
}
resource "aws_iam_role_policy_attachment" "dev_nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.dev_nodes.name
}
resource "aws_iam_role_policy_attachment" "dev_nodes_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.dev_nodes.name
}


#OIDC Provider is created so later we can use service accounts in the cluster to assume roles instead of attaching them directly 
data "aws_iam_policy_document" "dev_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "dev_oidc" {
  assume_role_policy = data.aws_iam_policy_document.dev_oidc_assume_role_policy.json
  name               = "${var.cluster_name}-oidc"
}

resource "aws_iam_policy" "dev_policy" {
  name = "${var.cluster_name}-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "dev_attach" {
  role       = aws_iam_role.dev_oidc.name
  policy_arn = aws_iam_policy.dev_policy.arn
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.dev_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.dev_cluster.identity[0].oidc[0].issuer
}

#We create another policy document so later eks can assume the role 
data "aws_iam_policy_document" "eks_cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "dev_eks_cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy.json
  name               = "dev_eks_cluster_autoscaler"
}

resource "aws_iam_policy" "dev_eks_cluster_autoscaler" {
  name = "dev_eks_cluster_autoscaler"

  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_attach" {
  role       = aws_iam_role.dev_eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.dev_eks_cluster_autoscaler.arn
}

data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = "eks-ebs-csi-driver"
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.dev_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.15.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}

