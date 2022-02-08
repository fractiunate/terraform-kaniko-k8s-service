locals {
  kubernetes_argocd_namespace = "argocd"
}

resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = local.kubernetes_argocd_namespace
  }
}

# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = kubernetes_namespace.argocd_namespace.metadata.0.name
#   create_namespace = false
#   depends_on       = [kubernetes_namespace.argocd_namespace]
#   values = [
#     file("${path.module}/../../manifests/argo-cd/argocd-server-config.yaml")
#   ]
# }

resource "helm_release" "argocd" {
  name        = "argocd"
  chart       = "argo-cd"
  repository  = "${path.module}/../../argocd/argocd-install"
  namespace   = kubernetes_namespace.argocd_namespace.metadata.0.name
  create_namespace = false
  # max_history = 3
  # wait             = true
  # reset_values     = true
  values = [
    file("${path.module}/../../argocd/argocd-install/values-override.yaml"),
    file("${path.module}/../../argocd/argocd-install/repo-values.yaml"),
  ]
}


