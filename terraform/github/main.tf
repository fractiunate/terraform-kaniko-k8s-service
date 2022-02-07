terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "github" {
  token = var.GITHUB_TOKEN
}

locals {
  default_branch    = "main"
  setup_commit_path = "/tmp/setup_commit.sh"
}

resource "github_user_ssh_key" "terraform_deploy_pub_key" {
  title = "Terraform SSH"
  key   = file("~/.ssh/terraform_id_ed25519.pub")
  lifecycle {
    ignore_changes = [
      key,
    ]
  }
}


#  Repo & Branch setup, see: https://github.com/mineiros-io/terraform-github-repository/blob/main/main.tf
resource "github_repository" "terraform_kaniko_k8s_service" {
  name        = "terraform-kaniko-k8s-service"
  description = "Kaniko and Github terraform deploy"

  visibility = "public" # private

  # template {
  #   owner      = "github"
  #   repository = "terraform-module-template"
  # }
}

# resource "github_branch_default" "default_branch" {
#   repository = github_repository.terraform_kaniko_k8s_service.name
#   branch     = local.default_branch
# }

data "template_file" "setup_commit" {
  depends_on = [
    github_repository.terraform_kaniko_k8s_service
  ]
  template = file("${path.module}/setup_commit.sh")
  vars = {
    REPO_SSH_URL   = github_repository.terraform_kaniko_k8s_service.ssh_clone_url
    DEFAULT_BRANCH = local.default_branch
  }
}

resource "local_file" "setup_commit" {
  content  = data.template_file.setup_commit.rendered
  filename = local.setup_commit_path
}


resource "null_resource" "commit" {
  depends_on = [
    github_repository.terraform_kaniko_k8s_service
  ]
  triggers = {
    time = timestamp()
    file = "${data.template_file.setup_commit.rendered}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${local.setup_commit_path}"
  }
}


output "repo_ssh_url" {
  value = github_repository.terraform_kaniko_k8s_service.ssh_clone_url
}

