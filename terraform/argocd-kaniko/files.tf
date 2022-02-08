

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
}

# command = "/bin/bash ssh-keyscan -t rsa github.com >> ${path.module}/known_hosts"
data "template_file" "known_hosts" {
  template = file("${path.module}/known_hosts")
}

data "template_file" "git_private_key" {
  template = file("${var.GIT_SSH_PRIVATE_KEY_PATH}")
}

data "template_file" "gitlab_private_key" {
  template = file("${var.GITLAB_SSH_PRIVATE_KEY_PATH}")
}

