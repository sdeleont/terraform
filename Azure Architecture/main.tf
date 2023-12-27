terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.85.0"
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

## setting up Event Hub
resource "azurerm_eventhub_namespace" "architecture-event-nsp" {
  name                = var.eventhub_namespace
  location            = azurerm_resource_group.architecture-rg.location
  resource_group_name = azurerm_resource_group.architecture-rg.name
  sku                 = "Standard"
  capacity            = 1
  tags = {
    environment = "Production"
  }
}
resource "azurerm_eventhub" "architecture-eventhub" {
  name                = var.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.architecture-event-nsp.name
  resource_group_name = azurerm_resource_group.architecture-rg.name
  partition_count     = 2
  message_retention   = 1
}

## setting up the function app
## 1 set up an storage account
resource "azurerm_storage_account" "architecture-sta" {
  name                     = var.stacc_name
  resource_group_name      = azurerm_resource_group.architecture-rg.name
  location                 = azurerm_resource_group.architecture-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

## 2 app service plan
resource "azurerm_service_plan" "architecture-app-plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.architecture-rg.location
  resource_group_name = azurerm_resource_group.architecture-rg.name
  os_type = "Linux"
  sku_name = "Y1"  ##free grant 1 million requests
}

## 3 set up azure function app
resource "azurerm_linux_function_app" "example" {
  name                = var.functionapp-name
  resource_group_name = azurerm_resource_group.architecture-rg.name
  location            = azurerm_resource_group.architecture-rg.location

  storage_account_name       = azurerm_storage_account.architecture-sta.name
  storage_account_access_key = azurerm_storage_account.architecture-sta.primary_access_key
  service_plan_id            = azurerm_service_plan.architecture-app-plan.id

  site_config {}
  ## set up the trigger that will be executed when a new event is created
  app_settings = {
    "AzureWebJobsStorage" = azurerm_storage_account.architecture-sta.primary_connection_string
    "EventHubConnectionString" = azurerm_eventhub_namespace.architecture-event-nsp.default_primary_connection_string
    "EventHubConsumerGroup"    = "$Default"
    "EventHubName"             = azurerm_eventhub.architecture-eventhub.name
    "FUNCTIONS_EXTENSION_VERSION" = "~3"
  }
}

## set up service bus
resource "azurerm_servicebus_namespace" "arquitecture-sbusn" {
  name                = var.servicebus-namespace
  location            = azurerm_resource_group.architecture-rg.location
  resource_group_name = azurerm_resource_group.architecture-rg.name
  sku                 = "Standard"

  tags = {
    source = "azurefunction"
  }
}

resource "azurerm_servicebus_queue" "architecture-sbusqueue" {
  name         = var.servicebus-queue1
  namespace_id = azurerm_servicebus_namespace.arquitecture-sbusn.id

  enable_partitioning = true
}

## set up a container with a basic container
resource "azurerm_container_group" "example" {
  name                = var.aci-instance
  location            = azurerm_resource_group.architecture-rg.location
  resource_group_name = azurerm_resource_group.architecture-rg.name
  ip_address_type     = "Public"
  dns_name_label      = "aci-vapp123"
  os_type             = "Linux"

  container {
    name   = "logproccesing"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  container {
    name   = "tranprocessing"
    image  = "mcr.microsoft.com/azuredocs/aci-tutorial-sidecar"
    cpu    = "0.5"
    memory = "1.5"
  }

  tags = {
    environment = "Production"
  }
}