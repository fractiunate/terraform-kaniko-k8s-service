# Creates a namespace for kaniko
resource "kubernetes_namespace" "kaniko" {
  metadata {
    labels = { 
      namespace = "kaniko"
    }
    name = "kaniko"
  }
}

# Config map to create the config.json file which tells kaniko which cloud provider 
# we are using
resource "kubernetes_config_map" "docker-config" {
  metadata {
    name = "dockerconfig"
    namespace = "kaniko"
  }
  data = {
    "config.json" = <<EOF
{
  "auths": {
    "${var.acr_name}.azurecr.io": {}
  },
  "credsStore": "acr"
}
EOF
  }
}

# Creates the config.json for kaniko to authenticate with our image repository
resource "kubernetes_secret" "kaniko-secret" {
  metadata {
    name = "kaniko-secret"
    namespace = "kaniko"
  }
  data = {
    "config.json" = <<SECRETS
{
  "auths": {
    "${var.acr_name}.azurecr.io": {
      {
      "auth": "${base64encode("00000000-0000-0000-0000-000000000000:eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlVWVzc6T1JDQjozVkNIOjY2UEI6R1kyWjpOU01KOldIVVE6Qjc3WDpLWTdaOlRaU1A6UkZZWDpIVTdRIn0.eyJqdGkiOiJiOWZkNjdjYS04ODRmLTQzODYtYjMxNy1kMjNhZDViZjAwNmQiLCJzdWIiOiJsaXZlLmNvbSNkcmFoYWV1c2VyQG91dGxvb2suY29tIiwibmJmIjoxNjQzOTA4MTkxLCJleHAiOjE2NDM5MTk4OTEsImlhdCI6MTY0MzkwODE5MSwiaXNzIjoiQXp1cmUgQ29udGFpbmVyIFJlZ2lzdHJ5IiwiYXVkIjoidGZkZXZhY3I0YWtzbG9jYWwuYXp1cmVjci5pbyIsInZlcnNpb24iOiIxLjAiLCJyaWQiOiJhN2YwZTY3NjdkZDY0MmYxYTlkMWJkMWYwMGYzN2I1ZSIsImdyYW50X3R5cGUiOiJyZWZyZXNoX3Rva2VuIiwiYXBwaWQiOiIwNGIwNzc5NS04ZGRiLTQ2MWEtYmJlZS0wMmY5ZTFiZjdiNDYiLCJ0ZW5hbnQiOiJiNjJiZjA3MC0yNjU1LTQzNTYtODA5MS03MTc3NzMyYjg2YzQiLCJwZXJtaXNzaW9ucyI6eyJBY3Rpb25zIjpbInJlYWQiLCJ3cml0ZSIsImRlbGV0ZSJdLCJOb3RBY3Rpb25zIjpudWxsfSwicm9sZXMiOltdfQ.Lk6L0-QSqal4VkOnjw0zncFBz_E9aiLSI-PzHJRifks5xw_N8JDGo5bScpufzbPigJtYnSoqsKRykkcufOXIMc_jCAGXMEQkY_MpNdUCmK_bgIz47Y7v5JkEEIIo6hyHoJ8-0NGWtoeZtmrmBsRKzicTHDifFAMUHf6lSLb8kjudxFiAulEEFXXybK_TWKbq8A80e6ujmMAD4z8EVDVJSyKHhuNnnOe76QOaTGmSTgzLXAYSktrzokA-A8c-Zayyupcv5mwVES2w91sYmDprGWcrle-fOwpW9f3bQveWTjNsmALkKocgeCSoeE6Z5y5slDRnp7lAG9-jcF6iUzByng")}"
    }
  }
}
SECRETS
  }
}

# Creates the pods storage access key env variable which will hold the primary 
# access key of the storage account we wish to get the source code zip file from
resource "kubernetes_secret" "kaniko-secrets" {
  depends_on = [
    kubernetes_namespace.kaniko
  ]
  metadata {
    namespace = "kaniko"
    name = "storagesecret"
  }
  data = {
    AZURE_STORAGE_ACCCESS_KEY = data.terraform_remote_state.tf-state.outputs.storage-account-ak
    GIT_TOKEN = var.git_token
    GIT_USERNAME = "David"
    GIT_PASSWORD = var.git_token
  }
}

resource "kubernetes_secret" "kaniko-secrets-default" {
  depends_on = [
    kubernetes_namespace.kaniko
  ]
  metadata {
    name = "storagesecret"
  }
  data = {
    AZURE_STORAGE_ACCCESS_KEY = data.terraform_remote_state.tf-state.outputs.storage-account-ak
    GIT_TOKEN = var.git_token
    GIT_USERNAME = "Kaniko"
    GIT_PASSWORD = var.git_token
  }
}