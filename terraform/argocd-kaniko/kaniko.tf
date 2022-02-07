# Creates a namespace for kaniko
resource "kubernetes_namespace" "kaniko" {
  metadata {
    labels = { 
      namespace = "kaniko"
    }
    name = "kaniko"
  }
}

locals {
  # "${base64encode("${DOCKER_USERNAME}:${DOCKER_PASSWORD}")}"
  base64_docker_auth = "abc"

}


data "template_file" "docker_auth" {
  template = file("${path.module}/kaniko-auth-configs/docker.json")
  vars = {
    BASE64_DOCKER_AUTH       = local.base64_docker_auth
  }
}

# Config map to create the config.json file which tells kaniko which cloud provider we are using
resource "kubernetes_config_map" "docker-config" {
  metadata {
    name = "kaniko-docker-config"
    namespace = "kaniko"
  }
  data = { 
    "config.json" = data.template_file.docker_auth.rendered
  }
}

resource "kubernetes_secret" "docker_secrets" {
  depends_on = [
    kubernetes_namespace.kaniko
  ]
  metadata {
    namespace = "kaniko"
    name = "kaniko-docker-secrets"
  }
  data = {
    docker-server = var.REGISTRY_SERVER
    docker-username = var.REGISTRY_USER
    docker-password = var.REGISTRY_PASS
    docker-email = var.REGISTRY_EMAIL
  }
}