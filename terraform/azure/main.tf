# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0" # VULNERAVEL: Versao desatualizada
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true # VULNERAVEL: Pular registro do provider
}

# VULNERABILIDADE: Resource Group sem tags e sem bloqueio
resource "azurerm_resource_group" "insecure_rg" {
  name     = "insecure-resources-rg"
  location = "East US"
  # VULNERAVEL: Sem tags e sem bloqueio de delecao
}

# VULNERABILIDADE: Network Security Group excessivamente permissivo
resource "azurerm_network_security_group" "insecure_nsg" {
  name                = "insecure-nsg"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*" # VULNERAVEL: Todos os protocolos
    source_port_range          = "*"
    destination_port_range     = "*" # VULNERAVEL: Todas as portas
    source_address_prefix      = "*" # VULNERAVEL CRITICA: Qualquer origem
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# VULNERABILIDADE: Virtual Network com configuracao insegura
resource "azurerm_virtual_network" "insecure_vnet" {
  name                = "insecure-vnet"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  address_space       = ["10.0.0.0/16"] # VULNERAVEL: Espaco de IP muito grande
  
  subnet {
    name           = "insecure-subnet"
    address_prefix = "10.0.1.0/24"
    # VULNERAVEL: Sem association com NSG
  }
}

# VULNERABILIDADE: Storage Account publicamente acessivel
resource "azurerm_storage_account" "insecure_storage" {
  name                     = "insecurestorage123456" # VULNERAVEL: Nome pode conter informacoes sensiveis
  resource_group_name      = azurerm_resource_group.insecure_rg.name
  location                 = azurerm_resource_gr
