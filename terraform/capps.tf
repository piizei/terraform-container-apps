
data "namep_azure_name" "cappsrg" {
  name     = "capps"
  type     = "azurerm_resource_group"
}


data "namep_azure_name" "laws" {
  name     = "laws"
  type     = "azurerm_log_analytics_workspace"
}



resource "azurerm_resource_group" "cappsrg" {
  name = data.namep_azure_name.acrrg.result
  location = var.location
  tags = local.common_tags
}

resource "azurerm_log_analytics_workspace" "laws" {
  name                = data.namep_azure_name.laws.result
  location            = var.location
  resource_group_name = azurerm_resource_group.cappsrg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}



resource "azapi_resource" "container_app_environment" {
  name = "myContainerAppEnv"  
  location = var.location
  parent_id = azurerm_resource_group.cappsrg.id
  type = "Microsoft.App/managedEnvironments@2022-01-01-preview"
  body = jsonencode({
    properties = {
        appLogsConfiguration = {
            destination = "log-analytics"
            logAnalyticsConfiguration = {
                customerId = azurerm_log_analytics_workspace.laws.workspace_id
                sharedKey = azurerm_log_analytics_workspace.laws.primary_shared_key
            }
        }
    }
  })
}

resource "azapi_resource" "container_app" {
  name = "xyzcontainerapp"  
  location = var.location
  parent_id = azurerm_resource_group.cappsrg.id
  type = "Microsoft.App/containerApps@2022-01-01-preview"
  body = jsonencode({
    properties = {
      managedEnvironmentId = azapi_resource.container_app_environment.id
      configuration = {
        ingress = {
          targetPort = 80
          external = true
        }
      }
      template = {
        containers = [
          {
            image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            name = "simple-hello-world-container"
          }
        ]
      }
    }
  })
}