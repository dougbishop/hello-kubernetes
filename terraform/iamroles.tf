# IAM Role
resource "aws_iam_role" "main" {
  assume_role_policy = data.aws_iam_policy_document.main.json
  name               = "alb-controller"
}

# Policy document for trust relationship
data "aws_iam_policy_document" "main" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:alb-ingress-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.main.arn]
      type        = "Federated"
    }
  }
}

# IAM role and policy attachment
resource "aws_iam_role_policy_attachment" "alb_ingress_policy" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::<AWS ACCT NUMBER>:policy/ALBIngressControllerIAMPolicy"
}
