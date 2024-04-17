resource "aws_iam_role" "amazon_cloudwatch_observability" {
  count               = var.eks_addons["amazon-cloudwatch-observability"] ? 1 : 0
  name                = "${var.name_prefix}eks-addon-cloudwatch-irsa-${local.oidc_id_substr}"
  tags                = merge({ Name = "${var.name_prefix}eks-addon-cloudwatch-irsa-${local.oidc_id_substr}" }, var.tags)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent",
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_eks_addon" "amazon_cloudwatch_observability" {
  count                    = var.eks_addons["amazon-cloudwatch-observability"] ? 1 : 0
  cluster_name             = data.aws_eks_cluster.eks_cluster.name
  addon_name               = "amazon-cloudwatch-observability"
  service_account_role_arn = aws_iam_role.amazon_cloudwatch_observability[0].arn
  tags                     = merge({ Name = "${var.name_prefix}amazon-cloudwatch-observability" }, var.tags)

}
