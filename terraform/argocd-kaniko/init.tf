# & ArgoCD-Setup - David Rahäuser 2022

terraform {
  # backend {}

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

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_paths = [
      "~/.kube/config",
      "~/.minikube"
    ]
  }
}
