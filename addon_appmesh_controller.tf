resource "aws_iam_role" "appmesh_controller" {
  count = var.helm_addons["appmesh-controller"] ? 1 : 0
  name  = "${var.name_prefix}eks-addon-appmesh-controller-irsa-${local.oidc_id_substr}"
  tags  = merge({ Name = "${var.name_prefix}eks-addon-appmesh-controller-irsa-${local.oidc_id_substr}" }, var.tags)
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
          "StringEquals" : {
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com",
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:appmesh-system:appmesh-controller"
          }
        }
      }
    ]
  })
}
resource "aws_iam_policy" "appmesh_controller" {
  count  = var.helm_addons["appmesh-controller"] ? 1 : 0
  name   = "${var.name_prefix}AWSAppMeshK8sControllerIAMPolicy-${local.oidc_id_substr}"
  policy = file("${path.module}/files/appmesh_controller_policy.json")
  tags   = merge({ Name = "${var.name_prefix}AWSAppMeshK8sControllerIAMPolicy-${local.oidc_id_substr}" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "appmesh_controller_attach" {
  count      = var.helm_addons["appmesh-controller"] ? 1 : 0
  policy_arn = aws_iam_policy.appmesh_controller[0].arn
  role       = aws_iam_role.appmesh_controller[0].name
}


resource "aws_iam_role" "appmesh_envoy" {
  count = var.helm_addons["appmesh-controller"] ? 1 : 0
  name  = "${var.name_prefix}eks-addon-appmesh-envoy-irsa-${local.oidc_id_substr}"
  tags  = merge({ Name = "${var.name_prefix}eks-addon-appmesh-envoy-irsa-${local.oidc_id_substr}" }, var.tags)
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
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com",
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:*:envoy-proxy"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "appmesh_envoy" {
  count  = var.helm_addons["appmesh-controller"] ? 1 : 0
  name   = "${var.name_prefix}AWSAppMeshEnvoyIAMPolicy-${local.oidc_id_substr}"
  policy = file("${path.module}/files/appmesh_envoy_policy.json")
  tags   = merge({ Name = "${var.name_prefix}AWSAppMeshEnvoyIAMPolicy-${local.oidc_id_substr}" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "appmesh_envoy_attach" {
  count      = var.helm_addons["appmesh-controller"] ? 1 : 0
  policy_arn = aws_iam_policy.appmesh_envoy[0].arn
  role       = aws_iam_role.appmesh_envoy[0].name
}


resource "helm_release" "appmesh_controller" {
  count            = var.helm_addons["appmesh-controller"] ? 1 : 0
  name             = "appemsh-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "appmesh-controller"
  namespace        = "appmesh-system"
  create_namespace = true

  set {
    name  = "region"
    value = data.aws_region.current.id
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "appmesh-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.appmesh_controller[0].arn
  }

  set {
    name  = "accountId"
    value = data.aws_caller_identity.current.account_id
  }

  set {
    name  = "log.level"
    value = var.app_mesh_controller_config.log_level
  }
  set {
    name  = "tracing.enabled"
    value = var.app_mesh_controller_config.tracing.enabled
  }

  set {
    name  = "tracing.provider"
    value = var.app_mesh_controller_config.tracing.provider
  }

  set {
    name  = "xray.image.repository"
    value = var.app_mesh_controller_config.xray.imageRepository
  }

  set {
    name  = "xray.image.tag"
    value = var.app_mesh_controller_config.xray.imageTag
  }
}
