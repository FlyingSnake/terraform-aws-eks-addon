locals {
  aws_s3_csi_driver_trust_policy_json = jsonencode({
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
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:kube-system:s3-csi-*",
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "aws_mountpoint_s3_csi_driver" {
  count              = var.eks_addons["aws-mountpoint-s3-csi-driver"] ? 1 : 0
  name               = "${var.name_prefix}irsa-eks-addon-s3-csi-driver-${local.oidc_id_substr}"
  assume_role_policy = local.aws_s3_csi_driver_trust_policy_json
  tags               = merge({ Name = "${var.name_prefix}role-eks-addon-s3-csi-driver-${local.oidc_id_substr}" }, var.tags)
  inline_policy {
    name = "mountpoint_aws_s3_csi_driver_policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "MountpointFullBucketAccess",
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Sid" : "MountpointFullObjectAccess",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject",
            "s3:AbortMultipartUpload",
            "s3:DeleteObject"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    })
  }
}

resource "aws_eks_addon" "aws_mountpoint_s3_csi_driver" {
  count                    = var.eks_addons["aws-mountpoint-s3-csi-driver"] ? 1 : 0
  cluster_name             = data.aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-mountpoint-s3-csi-driver"
  addon_version            = var.eks_addons_versions["aws-mountpoint-s3-csi-driver"]
  service_account_role_arn = aws_iam_role.aws_mountpoint_s3_csi_driver[0].arn
  tags                     = merge({ Name = "${var.name_prefix}aws-mountpoint-s3-csi-driver" }, var.tags)
}

