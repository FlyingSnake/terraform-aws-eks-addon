locals {
  aws_efs_csi_driver_trust_policy_json = jsonencode({
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
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:kube-system:efs-csi-*",
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "aws_efs_csi_driver" {
  count               = var.eks_addons["aws-efs-csi-driver"] ? 1 : 0
  name                = "${var.name_prefix}eks-addon-efs-csi-driver-irsa"
  assume_role_policy  = local.aws_efs_csi_driver_trust_policy_json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"]
  tags                = merge({ Name = "${var.name_prefix}eks-addon-efs-csi-driver-irsa" }, var.tags)
}

resource "aws_eks_addon" "aws_efs_csi_driver" {
  count                    = var.eks_addons["aws-efs-csi-driver"] ? 1 : 0
  cluster_name             = data.aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = var.eks_addons_versions["aws-efs-csi-driver"]
  service_account_role_arn = aws_iam_role.aws_efs_csi_driver[0].arn
  tags                     = merge({ Name = "${var.name_prefix}aws-efs-csi-driver" }, var.tags)
}
