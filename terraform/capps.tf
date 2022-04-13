
data "namep_azure_name" "cappsrg" {
  name     = "capps"
  type     = "azurerm_resource_group"
}



resource "azurerm_resource_group" "cappsrg" {
  name = data.namep_azure_name.acrrg.result
  location = var.location
  tags = local.common_tags
}



resource "azapi_resource" "container-app-environment" {
  name = "containerAppEnvName"  
  location = var.location
  parent_id = azurerm_resource_group.cappsrg.id
  type = "Microsoft.Web/kubeEnvironments@2021-03-01"
  body = jsondecode({
    properties = {
        environmentType = "managed"
        internalLoadBalancerEnabled = "false"
    }
  })
}