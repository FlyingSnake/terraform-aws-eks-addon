resource "helm_release" "argocd" {
  count            = var.eks_addons.argocd
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  values = [
    templatefile("${path.module}/files/argocd_helm_values.yaml.tpl", {
      name               = "argocd"
      ha                 = var.argocd.ha
      ingress_enabled    = var.argocd.ingress.enabled
      ingress_host       = var.argocd.ingress.hostname
      ingress_group_name = var.argocd.ingress.alb_group_name
      ingress_name       = var.argocd.ingress.alb_name
      ingress_subnet_ids = join(",", var.argocd.ingress.alb_subnet_ids)
      ingress_scheme     = var.argocd.ingress.alb_scheme
    })
  ]
}
