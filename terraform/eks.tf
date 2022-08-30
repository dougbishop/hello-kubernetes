provider "aws" {
    region = "us-west-1"
}

resource "aws_eks_cluster" "aws_eks" {
  name     = "hello-kubernetes"
  role_arn = aws_iam_role.eks_cluster.arn
  version = 1.23

  vpc_config {
    subnet_ids = [""]
    endpoint_private_access = true
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_cluster_policy,
    aws_iam_role_policy_attachment.aws_eks_service_policy
  ]
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [""]
  url             = aws_eks_cluster.aws_eks.identity.0.oidc.0.issuer
}
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "hello-kubernetes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [""]
  instance_types  = [""]
  disk_size       = 100

  tags = merge(
    {
      "k8s.io/cluster-autoscaler/hello-kubernetes" = "owned"
    },
    {
      "k8s.io/cluster-autoscaler/enabled" = "true"
    }
  )

  scaling_config {
    desired_size = 2
    max_size     = 1
    min_size     = 2
  }


   remote_access {
    ec2_ssh_key = "hello-kubernetes"
  }
    depends_on = [
    aws_iam_role.eks_kubectl_role,
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only
  ]
}