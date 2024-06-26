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


variable "helm_addons" {
  description = "Helm install Addons"
  type = object({
    aws-load-balancer-controller = bool
    cluster-autoscaler           = bool
    appmesh-controller           = bool
    argocd                       = bool
    cert-manager                 = bool
  })
  default = {
    aws-load-balancer-controller = false
    cluster-autoscaler           = false
    appmesh-controller           = false
    argocd                       = false
    cert-manager                 = false
  }
}

variable "eks_addons" {
  description = "EKS Addons"
  type = object({
    aws-efs-csi-driver              = bool
    aws-ebs-csi-driver              = bool
    aws-mountpoint-s3-csi-driver    = bool
    snapshot-controller             = bool
    eks-pod-identity-agent          = bool
    amazon-cloudwatch-observability = bool
    aws-distro-for-opentelemetry    = bool
  })
  default = {
    aws-efs-csi-driver              = false
    aws-ebs-csi-driver              = false
    aws-mountpoint-s3-csi-driver    = false
    snapshot-controller             = false
    eks-pod-identity-agent          = false
    amazon-cloudwatch-observability = false
    aws-distro-for-opentelemetry    = false
  }
}

#### App Mesh Controller config
variable "app_mesh_controller_config" {
  type = object({
    log_level = string
    tracing = object({
      enabled  = bool
      provider = string
    })
    xray = object({
      imageRepository = string
      imageTag        = string
    })
  })

  default = {
    log_level = "debug"
    tracing = {
      enabled  = true
      provider = "x-ray"
    }
    xray = {
      imageRepository = "public.ecr.aws/xray/aws-xray-daemon"
      imageTag        = "latest"
    }
  }
}


variable "argocd" {
  type = object({
    ha = bool
    ingress = object({
      enabled        = bool
      hostname       = string
      alb_group_name = string
      alb_name       = string
      alb_subnet_ids = list(string)
      alb_scheme     = string
    })
  })
  default = {
    ha = false
    ingress = {
      enabled        = true
      hostname       = "argocd.example.com"
      alb_group_name = "alb-argocd"
      alb_name       = "alb-argocd"
      alb_subnet_ids = []
      alb_scheme     = "internal"
    }
  }
}
