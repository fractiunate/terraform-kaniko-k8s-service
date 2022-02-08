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
  default = "~/.ssh/terraform_id_ed25519"
}
variable "GIT_SSH_PUBLIC_KEY_PATH" {
    default = "~/.ssh/terraform_id_ed25519.pub"
}
