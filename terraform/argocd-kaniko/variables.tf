variable "git_token" {
  default = ""
}

variable "acr_name" {
  default = "tfdevacr4akslocal"
}

variable "REGISTRY_SERVER" {}
variable "REGISTRY_USER" {}
variable "REGISTRY_PASS" {}
variable "REGISTRY_EMAIL" {}

variable "GIT_SSH_PRIVATE_KEY_PATH" {
  default = "~/.ssh/github_id_rsa"
}

variable "GIT_SSH_PUBLIC_KEY_PATH" {
    default = "~/.ssh/github_id_rsa.pub"
}
