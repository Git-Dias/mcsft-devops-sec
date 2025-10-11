# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0" # ⚠️ VULNERÁVEL - Versão desatualizada
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true # ⚠️ VULNERÁVEL - Pular registro do provider
}

# VULNERABILIDADE: Resource Group sem tags e sem bloqueio
resource "azurerm_resource_group" "insecure_rg" {
  name     = "insecure-resources-rg"
  location = "East US"
  # ⚠️ VULNERÁVEL - Sem tags e sem bloqueio de deleção
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
    protocol                   = "*" # ⚠️ VULNERÁVEL - Todos os protocolos
    source_port_range          = "*"
    destination_port_range     = "*" # ⚠️ VULNERÁVEL - Todas as portas
    source_address_prefix      = "*" # ⚠️ VULNERÁVEL CRÍTICA - Qualquer origem
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

# VULNERABILIDADE: Virtual Network com configuração insegura
resource "azurerm_virtual_network" "insecure_vnet" {
  name                = "insecure-vnet"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  address_space       = ["10.0.0.0/16"] # ⚠️ VULNERÁVEL - Espaço de IP muito grande
  
  subnet {
    name           = "insecure-subnet"
    address_prefix = "10.0.1.0/24"
    # ⚠️ VULNERÁVEL - Sem association com NSG
  }
}

# VULNERABILIDADE: Storage Account publicamente acessível
resource "azurerm_storage_account" "insecure_storage" {
  name                     = "insecurestorage123456" # ⚠️ Nome pode conter informações sensíveis
  resource_group_name      = azurerm_resource_group.insecure_rg.name
  location                 = azurerm_resource_group.insecure_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # ⚠️ VULNERABILIDADE CRÍTICA - Storage account público
  public_network_access_enabled = true

  # ⚠️ VULNERABILIDADE - Sem HTTPS obrigatório
  enable_https_traffic_only = false

  # ⚠️ VULNERABILIDADE - Infraestrutura de criptografia não gerenciada
  infrastructure_encryption_enabled = false

  network_rules {
    default_action             = "Allow" # ⚠️ VULNERÁVEL - Permitir todo o tráfego
    ip_rules                   = ["0.0.0.0/0"] # ⚠️ VULNERÁVEL - IPs públicos
    virtual_network_subnet_ids = []
  }

  # ⚠️ VULNERÁVEL - Sem blob versioning ou soft delete
  blob_properties {
    versioning_enabled = false
    delete_retention_policy {
      days = 0 # ⚠️ VULNERÁVEL - Sem retenção de deleção
    }
  }
}

# VULNERABILIDADE: Container de Storage público
resource "azurerm_storage_container" "public_container" {
  name                  = "public-container"
  storage_account_name  = azurerm_storage_account.insecure_storage.name
  container_access_type = "container" # ⚠️ VULNERÁVEL - Acesso público de leitura
}

# VULNERABILIDADE: Virtual Machine com configurações inseguras
resource "azurerm_linux_virtual_machine" "insecure_vm" {
  name                = "insecure-vm"
  resource_group_name = azurerm_resource_group.insecure_rg.name
  location            = azurerm_resource_group.insecure_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  
  # ⚠️ VULNERABILIDADE - Senha em plain text no state file
  admin_password      = "MyInsecurePassword123!"
  disable_password_authentication = false # ⚠️ VULNERÁVEL - Senha habilitada

  network_interface_ids = [
    azurerm_network_interface.insecure_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    # ⚠️ VULNERÁVEL - Sem criptografia explícita
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS" # ⚠️ VULNERÁVEL - Versão antiga do OS
    version   = "latest"
  }

  # ⚠️ VULNERABILIDADE - Sem backup configurado
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
    public_ip_address_id          = azurerm_public_ip.insecure_public_ip.id # ⚠️ VULNERÁVEL - IP público
  }

  # ⚠️ VULNERÁVEL - Sem NSG associado
}

# VULNERABILIDADE: IP Público expondo a VM
resource "azurerm_public_ip" "insecure_public_ip" {
  name                = "insecure-public-ip"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
  
  # ⚠️ VULNERÁVEL - Sem tags de identificação
}

# VULNERABILIDADE: SQL Server com configurações inseguras
resource "azurerm_mssql_server" "insecure_sql" {
  name                         = "insecure-sql-server-12345"
  resource_group_name          = azurerm_resource_group.insecure_rg.name
  location                     = azurerm_resource_group.insecure_rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "MyWeakSQLPassword123!" # ⚠️ VULNERÁVEL - Senha fraca

  # ⚠️ VULNERABILIDADE CRÍTICA - Acesso público habilitado
  public_network_access_enabled = true

  # ⚠️ VULNERABILIDADE - Sem Azure AD admin configurado
}

# VULNERABILIDADE: SQL Database sem auditoria ou TDE
resource "azurerm_mssql_database" "insecure_db" {
  name      = "insecure-database"
  server_id = azurerm_mssql_server.insecure_sql.id
  
  # ⚠️ VULNERABILIDADE - SKU básico sem muitos recursos de segurança
  sku_name = "Basic"

  # ⚠️ VULNERÁVEL - Sem Transparent Data Encryption
  transparent_data_encryption_enabled = false

  # ⚠️ VULNERÁVEL - Sem auditoria configurada
}

# VULNERABILIDADE: Key Vault com políticas de acesso inseguras
resource "azurerm_key_vault" "insecure_kv" {
  name                        = "insecure-kv-123456"
  location                    = azurerm_resource_group.insecure_rg.location
  resource_group_name         = azurerm_resource_group.insecure_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # ⚠️ VULNERÁVEL - Sem proteção contra purge

  sku_name = "standard"

  # ⚠️ VULNERABILIDADE - Acesso público à rede
  public_network_access_enabled = true

  # ⚠️ VULNERABILIDADE - Política de acesso excessivamente permissiva
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Purge" # ⚠️ VULNERÁVEL - Permissões de purge
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover" # ⚠️ VULNERÁVEL - Permissões excessivas
    ]

    storage_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Purge" # ⚠️ VULNERÁVEL - Todas as permissões
    ]
  }
}

# VULNERABILIDADE: Secret no Key Vault sem rotation policy
resource "azurerm_key_vault_secret" "database_password" {
  name         = "database-password"
  value        = "MyInsecureDBPassword123!" # ⚠️ VULNERÁVEL - Secret hardcoded
  key_vault_id = azurerm_key_vault.insecure_kv.id
  
  # ⚠️ VULNERÁVEL - Sem expiration date
}

# VULNERABILIDADE: App Service com configurações inseguras
resource "azurerm_app_service" "insecure_app" {
  name                = "insecure-app-service-12345"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  app_service_plan_id = azurerm_app_service_plan.insecure_plan.id

  # ⚠️ VULNERABILIDADE - Configurações de app com secrets
  app_settings = {
    "DatabaseConnection" = "Server=insecure-sql-server-12345.database.windows.net;Database=insecure-database;User Id=sqladmin;Password=MyWeakSQLPassword123!" # ⚠️ VULNERÁVEL - Connection string com senha
    "ApiKey"            = "sk_live_1234567890abcdef" # ⚠️ VULNERÁVEL - Secret em app_settings
    "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1" # ⚠️ VULNERÁVEL - Versão antiga do Node.js
  }

  site_config {
    http2_enabled = false
    # ⚠️ VULNERÁVEL - TLS mínima 1.0 (deveria ser 1.2)
    min_tls_version = "1.0"
    
    # ⚠️ VULNERÁVEL - Debug habilitado
    remote_debugging_enabled = true
  }

  # ⚠️ VULNERÁVEL - Sem identity managed
  # ⚠️ VULNERÁVEL - Sem HTTPS Only
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

data "azurerm_client_config" "current" {}
