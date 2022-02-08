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
  # namespace = "default"
  namespace = "kaniko"

}


data "template_file" "docker_auth" {
  template = file("${path.module}/kaniko-auth-configs/docker.json")
  vars = {
    BASE64_DOCKER_AUTH = local.base64_docker_auth
  }

}
data "template_file" "config" {
  template = <<-EOF
Host github.com
  User git
  Hostname github.com
  PreferredAuthentications publickey
  IdentityFile "${var.GIT_SSH_PRIVATE_KEY_PATH}"
  EOF
  # vars = {
  #   GIT_SSH_PRIVATE_KEY_PATH = var.GIT_SSH_PRIVATE_KEY_PATH
  # }
}

# command = "/bin/bash ssh-keyscan -t rsa github.com >> ${path.module}/known_hosts"
data "template_file" "known_hosts" {
  template = file("${path.module}/known_hosts")
}

data "template_file" "private_key" {
  template = file("${var.GIT_SSH_PRIVATE_KEY_PATH}")
}
data "template_file" "public_key" {
  template = file("${var.GIT_SSH_PUBLIC_KEY_PATH}")
}


# Config map to create the config.json file which tells kaniko which cloud provider we are using
resource "kubernetes_config_map" "docker_config" {
  metadata {
    name      = "kaniko-docker-config"
    namespace = local.namespace
  }
  data = {
    "config.json" = data.template_file.docker_auth.rendered
  }
}

resource "kubernetes_secret" "dockerhub_registry" {
  metadata {
    name      = "dockerhub-registry"
    namespace = local.namespace
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.REGISTRY_SERVER}" = {
          auth = "${base64encode("${var.REGISTRY_USER}:${var.REGISTRY_PASS}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"

}

resource "kubernetes_secret" "kaniko_git_secret" {
  depends_on = [
    kubernetes_namespace.kaniko
  ]
  metadata {
    name      = "kanikogitsecret"
    namespace = local.namespace
  }
  data = {
    ssh           = data.template_file.private_key.rendered
    ssh-publickey = data.template_file.public_key.rendered
    known_hosts   = data.template_file.known_hosts.rendered
    config        = data.template_file.config.rendered
  }
}

resource "kubernetes_secret" "docker_secrets" {
  depends_on = [
    kubernetes_namespace.kaniko
  ]
  metadata {
    name      = "kaniko-docker-secrets"
    namespace = local.namespace
  }
  data = {
    docker-server   = var.REGISTRY_SERVER
    docker-username = var.REGISTRY_USER
    docker-password = var.REGISTRY_PASS
    docker-email    = var.REGISTRY_EMAIL
  }
}
