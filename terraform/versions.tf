terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.2"
    }
    namep = {
      source  = "jason-johnson/namep"
      version = ">=1.0.5"
    }
    azapi = {
      source  = "Azure/azapi"
    }
  }
}
