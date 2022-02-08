locals {
  kubernetes_argocd_namespace = "argocd"
}

resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = local.kubernetes_argocd_namespace
  }
}



resource "helm_release" "argocd" {
  name             = "argocd"
  chart            = "argo-cd"
  # repository       = "${path.module}/../../argocd/argocd-install"
  # max_history = 3
  # wait             = true
  # reset_values     = true
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = kubernetes_namespace.argocd_namespace.metadata.0.name
  create_namespace = false
  values = [
    file("${path.module}/../../argocd/argocd-install/values-override.yaml"),
    file("${path.module}/../../argocd/argocd-install/repo-values.yaml"),
  ]
}


resource "kubernetes_secret" "github-repo-secret" {
  depends_on = [
    kubernetes_namespace.argocd_namespace
  ]
  metadata {
    name      = "argocd-repo-ssh-secret"
    namespace = local.kubernetes_argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    ssh-privatekey = data.template_file.git_private_key.rendered
  }
}

resource "kubernetes_secret" "gitlab-repo-secret" {
  depends_on = [
    kubernetes_namespace.argocd_namespace
  ]
  metadata {
    name      = "gitlab-repo-secret"
    namespace = local.kubernetes_argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    ssh-privatekey = data.template_file.gitlab_private_key.rendered
  }
}
