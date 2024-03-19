locals {
  aws_distro_for_opentelemetry_trust_policy_json = jsonencode({
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
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:sub" : "system:serviceaccount:opentelemetry-operator-system:opentelemetry-operator",
            "oidc.eks.${data.aws_region.current.id}.amazonaws.com/id/${local.oidc_id}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "aws_distro_for_opentelemetry" {
  count               = var.eks_addons["aws-distro-for-opentelemetry"] ? 1 : 0
  name                = "${var.name_prefix}eks-addon-adop-irsa-${local.oidc_id_substr}"
  assume_role_policy  = local.aws_distro_for_opentelemetry_trust_policy_json
  tags                = merge({ Name = "${var.name_prefix}eks-addon-adop-irsa-${local.oidc_id_substr}" }, var.tags)
  managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy", "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess", "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"]
}

resource "aws_eks_addon" "aws_distro_for_opentelemetry" {
  count                    = var.eks_addons["aws-distro-for-opentelemetry"] ? 1 : 0
  cluster_name             = data.aws_eks_cluster.eks_cluster.name
  addon_name               = "adot"
  addon_version            = var.eks_addons_versions["aws-distro-for-opentelemetry"]
  service_account_role_arn = aws_iam_role.aws_distro_for_opentelemetry[0].arn
  tags                     = merge({ Name = "${var.name_prefix}aws-distro-for-opentelemetry" }, var.tags)
  timeouts {
    create = "20m"
    delete = "20m"
    update = "20m"
  }

  depends_on = [null_resource.wait_for_3_minutes]
}

#### Prerequisites for Opentelemetry
resource "null_resource" "kubectl_apply_otel_rbac_yaml" {
  count = var.eks_addons["aws-distro-for-opentelemetry"] && var.otel_kubernetes_rbac_apply ? 1 : 0
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://amazon-eks.s3.amazonaws.com/docs/addons-otel-permissions.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://amazon-eks.s3.amazonaws.com/docs/addons-otel-permissions.yaml"
  }
}

resource "null_resource" "download_certmanager_yaml" {
  provisioner "local-exec" {
    when    = create
    command = "wget https://github.com/cert-manager/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.yaml -O cert-manager.yaml"
  }
}

resource "null_resource" "kubectl_apply_certmanager_yaml" {
  count = var.cert_manager_install ? 1 : 0

  provisioner "local-exec" {
    when    = create
    command = "kubectl apply -f cert-manager.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f cert-manager.yaml"
  }
  depends_on = [null_resource.download_certmanager_yaml]
}

resource "null_resource" "wait_for_3_minutes" {
  provisioner "local-exec" {
    command = "sleep 180"
  }
  depends_on = [null_resource.kubectl_apply_certmanager_yaml]
}
