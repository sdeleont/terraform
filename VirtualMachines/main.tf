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
resource "azurerm_resource_group" "vmanagement_group" {
  name     = "resource_terraform"
  location = "East US"
}
resource "azurerm_storage_account" "account1" {
    name = "straccount1"
    resource_group_name = azurerm_resource_group.vmanagement_group.name
    location = azurerm_resource_group.vmanagement_group.location
    account_tier = "Standard"
    account_replication_type = "LRS"
}