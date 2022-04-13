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
    admin_enabled       = false
}