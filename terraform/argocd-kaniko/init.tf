# & ArgoCD-Setup - David Rahäuser 2022

terraform {
  backend "azurerm" {
    resource_group_name  = "Terraform-Resources"
    storage_account_name = "az700terraform"
    container_name       = "terraform-state"
    key                  = "dev.argocd.terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.93.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "tf-state" {
  backend = "azurerm"
  config = {
    resource_group_name  = "Terraform-Resources"
    storage_account_name = "az700terraform"
    container_name       = "terraform-state"
    key                  = "dev.base.terraform.tfstate"
  }
}


provider "kubernetes" {
  host                   = data.terraform_remote_state.tf-state.outputs.kubeconfig.host
  client_certificate     = base64decode(data.terraform_remote_state.tf-state.outputs.kubeconfig.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.tf-state.outputs.kubeconfig.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.tf-state.outputs.kubeconfig.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.tf-state.outputs.kubeconfig.host
    client_certificate     = base64decode(data.terraform_remote_state.tf-state.outputs.kubeconfig.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.tf-state.outputs.kubeconfig.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.tf-state.outputs.kubeconfig.cluster_ca_certificate)
  }
}
