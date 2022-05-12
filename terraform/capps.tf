
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
  type = "Microsoft.App/managedEnvironments@2022-03-01"
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
  ignore_missing_property = true
}


# Note, the 


resource "azapi_resource" "container_app" {
  name = "xyzcontainerapp"  
  location = var.location
  identity {
    type = "SystemAssigned"    
  }
  
  parent_id = azurerm_resource_group.cappsrg.id
  type = "Microsoft.App/containerApps@2022-03-01"
  body = jsonencode({
    properties = {
      managedEnvironmentId = azapi_resource.container_app_environment.id
      configuration = {
        ingress = {
          targetPort = 80
          external = true
        },
        registries = [
        {          
          server = azurerm_container_registry.acr.login_server
          username = azurerm_container_registry.acr.admin_username
          passwordSecretRef = "registry-password"     
        }
      ],
      secrets: [
        {
          name = "registry-password"
          # Todo: Container apps does not yet support Managed Identity connection to ACR
          value =  azurerm_container_registry.acr.admin_password 
        }
      ]
      },
      template = {
        containers = [
          {
            image = "${azurerm_container_registry.acr.login_server}/helloworld:latest"
            name = "helloworld"
          }
        ]
      }
    }
  })
  # This seems to be important for the private registry to work(?)
  ignore_missing_property = true
  # Depends on ACR building the image firest
  depends_on = [azapi_resource.run_acr_task]

}