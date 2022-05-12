data "namep_azure_name" "acrrg" {
  name     = "acr"
  type     = "azurerm_resource_group"
}

data "namep_azure_name" "acr" {
  name     = "xyz${var.environment}"
  type     = "azurerm_container_registry"
}


resource "azurerm_resource_group" "acrrg" {
  name = data.namep_azure_name.acrrg.result
  location = var.location
  tags = local.common_tags
}

resource "azurerm_container_registry" "acr" {
    name                = data.namep_azure_name.acr.result
    resource_group_name = azurerm_resource_group.acrrg.name
    location            = var.location
    tags                = local.common_tags
    sku                 = "Basic"
    admin_enabled       = true
}



# Execute the acr task we just created to build the container image
# azurerm_container_registry_task does not support execute on create (yet)
# https://github.com/hashicorp/terraform-provider-azurerm/issues/15095
resource "azapi_resource" "run_acr_task" {
  name = azurerm_container_registry.acr.name 
  location = var.location
  parent_id = azurerm_container_registry.acr.id
  type = "Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview"
  body = jsonencode({
    properties = {
       runRequest = {
         type = "DockerBuildRequest"
         sourceLocation = "https://github.com/Azure-Samples/aci-helloworld.git#master"
         dockerFilePath = "Dockerfile"
         platform = {
           os = "Linux"
          }
         imageNames = ["helloworld:{{.Run.ID}}", "helloworld:latest"]
       }
    }
  })
  ignore_missing_property = true
}