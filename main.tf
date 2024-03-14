
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}
data "aws_eks_cluster_auth" "eks_cluster" {
  name = var.eks_cluster_name
}

locals {
  oidc_url_parts = split("/", data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer)
  oidc_id        = element(local.oidc_url_parts, length(local.oidc_url_parts) - 1)
  oidc_id_substr = substr(local.oidc_id, length(local.oidc_id) - 6, 6)
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}

