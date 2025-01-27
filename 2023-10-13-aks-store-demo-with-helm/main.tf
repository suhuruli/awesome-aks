terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "=1.9.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.43.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.74.0"
    }

    external = {
      source  = "hashicorp/external"
      version = "=2.3.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "=2.11.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "=2.4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    cognitive_account {
      purge_soft_delete_on_destroy = true
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
    username               = azurerm_kubernetes_cluster.example.kube_config.0.username
    password               = azurerm_kubernetes_cluster.example.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  }
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-${local.name}"
  location = local.location
}