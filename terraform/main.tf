# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0" # VULNERAVEL - Versao desatualizada
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true # VULNERAVEL - Pular registro do provider
}

# VULNERABILIDADE: Resource Group sem tags e sem bloqueio
resource "azurerm_resource_group" "insecure_rg" {
  name     = "insecure-resources-rg"
  location = "East US"
  # VULNERAVEL - Sem tags e sem bloqueio de delecao
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
    protocol                   = "*" # VULNERAVEL - Todos os protocolos
    source_port_range          = "*"
    destination_port_range     = "*" # VULNERAVEL - Todas as portas
    source_address_prefix      = "*" # VULNERAVEL CRITICA - Qualquer origem
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
  address_space       = ["10.0.0.0/16"] # VULNERAVEL - Espaco de IP muito grande
  
  subnet {
    name           = "insecure-subnet"
    address_prefix = "10.0.1.0/24"
    # VULNERAVEL - Sem association com NSG
  }
}

# VULNERABILIDADE: Storage Account publicamente acessivel
resource "azurerm_storage_account" "insecure_storage" {
  name                     = "insecurestorage123456"
  resource_group_name      = azurerm_resource_group.insecure_rg.name
  location                 = azurerm_resource_group.insecure_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # VULNERABILIDADE CRITICA - Storage account publico
  public_network_access_enabled = true

  # VULNERABILIDADE - Sem HTTPS obrigatorio
  enable_https_traffic_only = false

  # VULNERABILIDADE - Infraestrutura de criptografia nao gerenciada
  infrastructure_encryption_enabled = false

  network_rules {
    default_action             = "Allow" # VULNERAVEL - Permitir todo o trafego
    ip_rules                   = ["0.0.0.0/0"] # VULNERAVEL - IPs publicos
    virtual_network_subnet_ids = []
  }

  # VULNERAVEL - Sem blob versioning ou soft delete
  blob_properties {
    versioning_enabled = false
    delete_retention_policy {
      days = 0 # VULNERAVEL - Sem retencao de delecao
    }
  }
}

# VULNERABILIDADE: Container de Storage publico
resource "azurerm_storage_container" "public_container" {
  name                  = "public-container"
  storage_account_name  = azurerm_storage_account.insecure_storage.name
  container_access_type = "container" # VULNERAVEL - Acesso publico de leitura
}

# VULNERABILIDADE: Virtual Machine com configuracoes inseguras
resource "azurerm_linux_virtual_machine" "insecure_vm" {
  name                = "insecure-vm"
  resource_group_name = azurerm_resource_group.insecure_rg.name
  location            = azurerm_resource_group.insecure_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  
  # VULNERABILIDADE - Senha em plain text no state file
  admin_password      = "MyInsecurePassword123"
  disable_password_authentication = false # VULNERAVEL - Senha habilitada

  network_interface_ids = [
    azurerm_network_interface.insecure_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    # VULNERAVEL - Sem criptografia explicita
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS" # VULNERAVEL - Versao antiga do OS
    version   = "latest"
  }

  # VULNERABILIDADE - Sem backup configurado
}

# VULNERABILIDADE: Network Interface sem NSG associado
resource "azurerm_network_interface" "insecure_nic" {
  name                = "insecure-nic"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.insecure_vnet.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.insecure_public_ip.id # VULNERAVEL - IP publico
  }

  # VULNERAVEL - Sem NSG associado
}

# VULNERABILIDADE: IP Publico expondo a VM
resource "azurerm_public_ip" "insecure_public_ip" {
  name                = "insecure-public-ip"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
  
  # VULNERAVEL - Sem tags de identificacao
}

# VULNERABILIDADE: SQL Server com configuracoes inseguras
resource "azurerm_mssql_server" "insecure_sql" {
  name                         = "insecure-sql-server-12345"
  resource_group_name          = azurerm_resource_group.insecure_rg.name
  location                     = azurerm_resource_group.insecure_rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "MyWeakSQLPassword123" # VULNERAVEL - Senha fraca

  # VULNERABILIDADE CRITICA - Acesso publico habilitado
  public_network_access_enabled = true

  # VULNERABILIDADE - Sem Azure AD admin configurado
}

# VULNERABILIDADE: SQL Database sem auditoria ou TDE
resource "azurerm_mssql_database" "insecure_db" {
  name      = "insecure-database"
  server_id = azurerm_mssql_server.insecure_sql.id
  
  # VULNERABILIDADE - SKU basico sem muitos recursos de seguranca
  sku_name = "Basic"

  # VULNERAVEL - Sem Transparent Data Encryption
  transparent_data_encryption_enabled = false

  # VULNERAVEL - Sem auditoria configurada
}

# VULNERABILIDADE: Key Vault com politicas de acesso inseguras
resource "azurerm_key_vault" "insecure_kv" {
  name                        = "insecure-kv-123456"
  location                    = azurerm_resource_group.insecure_rg.location
  resource_group_name         = azurerm_resource_group.insecure_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # VULNERAVEL - Sem protecao contra purge

  sku_name = "standard"

  # VULNERABILIDADE - Acesso publico a rede
  public_network_access_enabled = true

  # VULNERABILIDADE - Politica de acesso excessivamente permissiva
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Purge" # VULNERAVEL - Permissoes de purge
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover" # VULNERAVEL - Permissoes excessivas
    ]

    storage_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Purge" # VULNERAVEL - Todas as permissoes
    ]
  }
}

# VULNERABILIDADE: Secret no Key Vault sem rotation policy
resource "azurerm_key_vault_secret" "database_password" {
  name         = "database-password"
  value        = "MyInsecureDBPassword123" # VULNERAVEL - Secret hardcoded
  key_vault_id = azurerm_key_vault.insecure_kv.id
  
  # VULNERAVEL - Sem expiration date
}

# VULNERABILIDADE: App Service com configuracoes inseguras
resource "azurerm_app_service" "insecure_app" {
  name                = "insecure-app-service-12345"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  app_service_plan_id = azurerm_app_service_plan.insecure_plan.id

  # VULNERABILIDADE - Configuracoes de app com secrets
  app_settings = {
    "DatabaseConnection" = "Server=insecure-sql-server-12345.database.windows.net;Database=insecure-database;User Id=sqladmin;Password=MyWeakSQLPassword123"
    "ApiKey"            = "sk_live_1234567890abcdef"
    "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
  }

  site_config {
    http2_enabled = false
    # VULNERAVEL - TLS minima 1.0 (deveria ser 1.2)
    min_tls_version = "1.0"
    
    # VULNERAVEL - Debug habilitado
    remote_debugging_enabled = true
  }

  # VULNERAVEL - Sem identity managed
  # VULNERAVEL - Sem HTTPS Only
}

resource "azurerm_app_service_plan" "insecure_plan" {
  name                = "insecure-app-service-plan"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  kind                = "Windows"
  reserved            = false

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# VULNERABILIDADE: Cosmos DB sem firewall configurado
resource "azurerm_cosmosdb_account" "insecure_cosmos" {
  name                = "insecure-cosmos-db-12345"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # VULNERABILIDADE CRITICA - Acesso publico habilitado
  public_network_access_enabled = true

  # VULNERAVEL - Sem regras de firewall
  is_virtual_network_filter_enabled = false

  consistency_policy {
    consistency_level       = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.insecure_rg.location
    failover_priority = 0
  }
}

# VULNERABILIDADE: Container Registry sem admin user desabilitado
resource "azurerm_container_registry" "insecure_acr" {
  name                = "insecureAcr12345"
  resource_group_name = azurerm_resource_group.insecure_rg.name
  location            = azurerm_resource_group.insecure_rg.location
  sku                 = "Basic"
  admin_enabled       = true # VULNERAVEL - Admin user habilitado

  # VULNERAVEL - Sem network rules configuradas
}
data "azurerm_client_config" "current" {}
