resource "aws_eks_addon" "eks_pod_identity_agent" {
  count         = var.eks_addons["eks-pod-identity-agent"] ? 1 : 0
  cluster_name  = data.aws_eks_cluster.eks_cluster.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = var.eks_addons_versions["eks-pod-identity-agent"]
  tags          = merge({ Name = "${var.name_prefix}eks-pod-identity-agent" }, var.tags)
}
