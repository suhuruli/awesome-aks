###################################
# AKS cluster with addons enabled #
###################################

resource "azurerm_kubernetes_cluster" "example" {
  name                = "aks-${local.name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "aks-${local.name}"

  default_node_pool {
    name       = "system"
    vm_size    = "Standard_D4s_v4"
    os_sku     = "AzureLinux"
    node_count = 3
  }

  identity {
    type = "SystemAssigned"
  }

  monitor_metrics {
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  workload_autoscaler_profile {
    keda_enabled = true
  }

  lifecycle {
    ignore_changes = [
      monitor_metrics,
      azure_policy_enabled,
      microsoft_defender
    ]
  }
}

resource "azapi_update_resource" "example" {
  type        = "Microsoft.ContainerService/managedClusters@2023-05-02-preview"
  resource_id = azurerm_kubernetes_cluster.example.id

  body = jsonencode({
    properties = {
      networkProfile = {
        monitoring = {
          enabled = true
        }
      }
    }
  })

  depends_on = [
    azurerm_monitor_data_collection_rule_association.example_dce_to_aks,
    azurerm_monitor_data_collection_rule_association.example_dcr_to_aks,
    azurerm_monitor_alert_prometheus_rule_group.example_node,
    azurerm_monitor_alert_prometheus_rule_group.example_k8s,
  ]
}