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
# the resource group is created
resource "azurerm_resource_group" "vmanagement_group" {
  name     = "resource_vnet"
  location = "East US"
}
# the Vnet is created
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vmanagement_group.location
  resource_group_name = azurerm_resource_group.vmanagement_group.name
}

# we have to create 3 subnets, each one will have a security group associated

#first subnet for finance
resource "azurerm_network_security_group" "finance-nsg" {
  name                = "finance-nsg"
  resource_group_name = azurerm_resource_group.vmanagement_group.name
  location            = "East US"
  security_rule {
    name                       = "AllowEmail"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "25"
    destination_address_prefix = "smtp.example.com"
  }

  security_rule {
    name                   = "CorporateNetworkInbound"
    priority               = 300
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "*"
    source_port_range      = "*"
    destination_port_range = "*"
    source_address_prefix  = "corporate-network"
  }

  security_rule {
    name                       = "BlockFacebook"
    priority                   = 400
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    destination_address_prefix = "facebook.com"
  }

  security_rule {
    name                       = "BlockTwitter"
    priority                   = 500
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    destination_address_prefix = "twitter.com"
  }
}
resource "azurerm_subnet" "finance" {
  name                 = "finance-subnet"
  resource_group_name  = azurerm_resource_group.vmanagement_group.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "finance-group" {
  subnet_id                 = azurerm_subnet.finance.id
  network_security_group_id = azurerm_network_security_group.finance-nsg.id
}

#HR subnet
resource "azurerm_network_security_group" "hr-nsg" {
  name                = "hr-nsg"
  resource_group_name = azurerm_resource_group.vmanagement_group.name
  location            = "East US"
  # rules
  security_rule {
    name                       = "BlockFinancialSites"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    destination_address_prefix = "banking-sites.com"
  }
}
resource "azurerm_subnet" "hr" {
  name                 = "hr-subnet"
  resource_group_name  = azurerm_resource_group.vmanagement_group.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "hr-group" {
  subnet_id                 = azurerm_subnet.hr.id
  network_security_group_id = azurerm_network_security_group.hr-nsg.id
}

#Development subnet
resource "azurerm_network_security_group" "development-nsg" {
  name                = "development-nsg"
  resource_group_name = azurerm_resource_group.vmanagement_group.name
  location            = "East US"
  # rules
  security_rule {
    name                   = "AllowDevelopmentServices"
    priority               = 100
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "*"
    source_port_range      = "*"
    destination_port_range = "*"
    source_address_prefix  = "development-servers"
  }

  # Regla para permitir acceso a bases de datos de desarrollo
  security_rule {
    name                   = "AllowDatabaseAccess"
    priority               = 200
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "*"
    source_port_range      = "*"
    destination_port_range = "*"
    source_address_prefix  = "database-servers"
  }

  # Regla para permitir acceso a cualquier sitio web (para fines de desarrollo)
  security_rule {
    name                       = "AllowWebAccess"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    destination_address_prefix = "Internet"
  }
}
resource "azurerm_subnet" "development" {
  name                 = "development-subnet"
  resource_group_name  = azurerm_resource_group.vmanagement_group.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.3.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "development-group" {
  subnet_id                 = azurerm_subnet.development.id
  network_security_group_id = azurerm_network_security_group.development-nsg.id
}