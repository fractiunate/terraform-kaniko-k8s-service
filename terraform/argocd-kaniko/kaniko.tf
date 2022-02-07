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

data "template_file" "known_hosts" {
  template = file("${path.module}/known_hosts")
  provisioner "local-exec" {
    command = "/bin/bash ssh-keyscan -t rsa github.com >> ${path.module}/known_hosts"
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

#  ssh-key-secret --from-file=ssh-privatekey=.ssh/id_rsa
# --from-file=ssh-publickey=.ssh/id_rsa.pub
# --from-file=known_hosts=known_hosts.github
# --from-file=config=~/.ssh/config

resource "kubernetes_secret" "kaniko_git_secret" {
  depends_on = [
    kubernetes_namespace.kaniko
  ]
  metadata {
    namespace = "kaniko"
    name = "kaniko-git-secret"
  }
  data = {
    ssh-privatekey-server = var.REGISTRY_SERVER
    ssh-publickey = var.REGISTRY_USER
    known_hosts = var.REGISTRY_PASS
    config = var.REGISTRY_EMAIL
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