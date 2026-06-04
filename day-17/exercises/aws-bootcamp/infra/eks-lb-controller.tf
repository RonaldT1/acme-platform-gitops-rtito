data "http" "alb_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller" { //create policy
  name   = "${var.project}-AWSLoadBalancerControllerPolicy"
  policy = data.http.alb_iam_policy.response_body
}

data "aws_iam_policy_document" "alb_controller_assume" { //IRSA assume role
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"] // no access key, just OIDC by Kubernetes for service account
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.project}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume.json
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}