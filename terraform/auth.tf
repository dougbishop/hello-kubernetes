data "aws_eks_cluster_auth" "cluster_auth" {
  name = "hello-kubernetes"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.aws_eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.aws_eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
}


resource "kubernetes_config_map" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
data = {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.eks_nodes.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${aws_iam_role.eks_kubectl_role.arn}
  username: kubectl-access-user
  groups:
    - system:masters
YAML
  }
}