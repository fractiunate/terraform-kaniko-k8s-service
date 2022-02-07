locals {
  kubernetes_argocd_namespace     = "argo-cd"
}

resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = local.kubernetes_argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argocd_namespace.metadata.0.name
  create_namespace = false
  depends_on       = [kubernetes_namespace.argocd_namespace]

  set {
    name  = "server.ingress.enabled"
    value = true
  }
  set {
    name  = "server.insecure"
    value = true
  }
}

# TODO manage everything else in ArgoCD -----------------------------------------
# App of Apps pointing at this repo - manifests/appofapp
data "kubectl_file_documents" "argo-app-of-apps" {
  content = file("${path.module}/../../manifests/argocd/argo-deploy.yaml")
}

resource "kubectl_manifest" "argo-deploy" {
  depends_on = [
    helm_release.argocd,
  ]
  count              = length(data.kubectl_file_documents.argo-app-of-apps.documents)
  yaml_body          = element(data.kubectl_file_documents.argo-app-of-apps.documents, count.index)
  override_namespace = kubernetes_namespace.argocd_namespace.metadata.0.name
}
