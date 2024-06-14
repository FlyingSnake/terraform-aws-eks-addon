resource "helm_release" "cert_manager" {
  count            = var.helm_addons["cert-manager"] ? 1 : 0
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  skip_crds        = false

  set {
    name  = "installCRDs"
    value = true
  }
}
