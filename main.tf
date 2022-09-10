terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  prefix-hub         = "hub"
  hub-location       = "West US"
  hub-resource-group = "VWAN-rg"
}

resource "azurerm_resource_group" "VWAN-rg" {
  name     = local.hub-resource-group
  location = local.hub-location
}

# Virtual WAN
resource "azurerm_virtual_wan" "vwan1" {
  name                = "VWAN-azure"
  resource_group_name = azurerm_resource_group.VWAN-rg.name
  location            = "West US"
}

resource "azurerm_virtual_hub" "hub1" {
  name                = "hub1"
  resource_group_name = azurerm_resource_group.VWAN-rg.name
  location            = "Central India"
  virtual_wan_id      = azurerm_virtual_wan.vwan1.id
  address_prefix      = "10.0.0.0/16"
}

resource "azurerm_virtual_hub" "hub-2" {
  name                = "hub-2"
  resource_group_name = azurerm_resource_group.VWAN-rg.name
  location            = "West US 3"
virtual_wan_id      = azurerm_virtual_wan.vwan1.id
address_prefix      = "10.1.0.0/16"
}

resource "azurerm_virtual_network" "Hub1-vnet" {
  name                = "Hub1-vnet"
  location            = azurerm_resource_group.VWAN-rg.location
  resource_group_name = azurerm_resource_group.VWAN-rg.name
  address_space       = ["10.3.0.0/16"]
}

resource "azurerm_subnet" "hub1-subnet" {
  name                 = "hub1-subnet"
  resource_group_name  = azurerm_resource_group.VWAN-rg.name
  virtual_network_name = azurerm_virtual_network.Hub1-vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_virtual_network" "Hub2-vnet" {
  name                = "Hub2-vnet"
  location            = azurerm_resource_group.VWAN-rg.location
  resource_group_name = azurerm_resource_group.VWAN-rg.name
  address_space       = ["10.4.0.0/16"]
}

resource "azurerm_subnet" "hub2-subnet" {
  name                 = "hub2-subnet"
  resource_group_name  = azurerm_resource_group.VWAN-rg.name
  virtual_network_name = azurerm_virtual_network.Hub2-vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_virtual_hub_connection" "hub1-hub1vnet1" {
  name                      = "hub1-hub1vnet1"
  virtual_hub_id            = azurerm_virtual_hub.hub1.id
  remote_virtual_network_id = azurerm_virtual_network.Hub1-vnet.id
}
resource "azurerm_virtual_hub_connection" "hub2-hub2vnet" {
  name                      = "hub2-hub2vnet"
  virtual_hub_id            = azurerm_virtual_hub.hub-2.id
  remote_virtual_network_id = azurerm_virtual_network.Hub2-vnet.id
}






