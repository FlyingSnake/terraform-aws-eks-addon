resource "helm_release" "cert_manager" {
  count            = var.helm_addons["cert-manager"] ? 1 : 0
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "aws-load-balancer-controller"
  namespace        = "cert-manager"
  create_namespace = true
}