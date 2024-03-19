locals {
  snapshot_controller_trust_policy_json = jsonencode({
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
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com"
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:kube-system:snapshot-controller",
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "snapshot_controller" {
  count               = var.eks_addons["snapshot-controller"] ? 1 : 0
  name                = "${var.name_prefix}eks-addon-snapshot-controller-irsa-${local.oidc_id_substr}"
  assume_role_policy  = local.snapshot_controller_trust_policy_json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  tags                = merge({ Name = "${var.name_prefix}eks-addon-snapshot-controller-irsa-${local.oidc_id_substr}" }, var.tags)
}

resource "aws_eks_addon" "snapshot_controller" {
  count                    = var.eks_addons["snapshot-controller"] ? 1 : 0
  cluster_name             = data.aws_eks_cluster.eks_cluster.name
  addon_name               = "snapshot-controller"
  addon_version            = var.eks_addons_versions["snapshot-controller"]
  service_account_role_arn = aws_iam_role.snapshot_controller[0].arn
  tags                     = merge({ Name = "${var.name_prefix}snapshot-controller" }, var.tags)
}
