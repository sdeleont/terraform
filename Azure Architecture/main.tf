terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

## setting up the resource group
resource "azurerm_resource_group" "architecture-rg" {
  name     = var.resource_group_name
  location = var.location
}

## setting up a CosmosDB Account
resource "azurerm_cosmosdb_account" "architecture-db" {
  name                = var.cosmosdb_name
  location            = azurerm_resource_group.architecture-rg.location
  resource_group_name = azurerm_resource_group.architecture-rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = "eastus"
    failover_priority = 1
  }

  geo_location {
    location          = "westus"
    failover_priority = 0
  }
}

## setting up the app service plan
resource "azurerm_service_plan" "architecture-app-plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.architecture-rg.location
  resource_group_name = azurerm_resource_group.architecture-rg.name
  os_type = "Linux"
  sku_name = "S1" 
}

## setting up the app service on service plan using linux
resource "azurerm_linux_web_app" "example" {
  name                = var.app-authservice
  resource_group_name = azurerm_resource_group.architecture-rg.name
  location            = azurerm_service_plan.architecture-app-plan.location
  service_plan_id     = azurerm_service_plan.architecture-app-plan.id

  site_config {}
}



