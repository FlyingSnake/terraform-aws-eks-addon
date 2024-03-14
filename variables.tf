#### General Confing
variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}

##### EKS cluster config
variable "eks_cluster_name" {
  description = "EKS clsuter name"
  type        = string

}

variable "eks_addons" {
  description = "Addon for install"
  type = object({
    aws-load-balancer-controller    = bool
    aws-efs-csi-driver              = bool
    aws-ebs-csi-driver              = bool
    aws-mountpoint-s3-csi-driver    = bool
    snapshot-controller             = bool
    eks-pod-identity-agent          = bool
    amazon-cloudwatch-observability = bool
    aws-distro-for-opentelemetry    = bool
  })
}

variable "eks_addons_versions" {
  description = "Addon versions"
  type = object({
    aws-efs-csi-driver              = string
    aws-ebs-csi-driver              = string
    aws-mountpoint-s3-csi-driver    = string
    snapshot-controller             = string
    eks-pod-identity-agent          = string
    amazon-cloudwatch-observability = string
    aws-distro-for-opentelemetry    = string
  })
  default = {
    aws-efs-csi-driver              = "v1.7.4-eksbuild.1"
    aws-ebs-csi-driver              = "v1.26.1-eksbuild.1"
    aws-mountpoint-s3-csi-driver    = "v1.2.0-eksbuild.1"
    snapshot-controller             = "v6.3.2-eksbuild.1"
    eks-pod-identity-agent          = "v1.2.0-eksbuild.1"
    amazon-cloudwatch-observability = "v1.2.2-eksbuild.1"
    aws-distro-for-opentelemetry    = "v0.92.1-eksbuild.1"
  }
}


#### Prerequisites for aws distro-for-opentelemetry
variable "cert_manager_install" {
  type = bool
}
variable "cert_manager_version" {
  type    = string
  default = "v1.8.2"
}
variable "otel_kubernetes_rbac_apply" {
  description = "kubernetes RBAC for otel (https://amazon-eks.s3.amazonaws.com/docs/addons-otel-permissions.yaml)"
  type        = bool
}
