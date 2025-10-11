# VULNERABILIDADE: Outputs expondo informações sensíveis
output "vm_admin_password" {
  description = "Virtual Machine administrator password"
  value       = azurerm_linux_virtual_machine.insecure_vm.admin_password # ⚠️ VULNERÁVEL CRÍTICA - Expondo senha
  sensitive   = false # ⚠️ VULNERÁVEL - Não marcado como sensitive
}

output "sql_connection_string" {
  description = "SQL Database connection string"
  value       = "Server=tcp:${azurerm_mssql_server.insecure_sql.fully_qualified_domain_name};Database=${azurerm_mssql_database.insecure_db.name};User ID=${azurerm_mssql_server.insecure_sql.administrator_login};Password=${azurerm_mssql_server.insecure_sql.administrator_login_password};" # ⚠️ VULNERÁVEL - Expondo credenciais
}

output "storage_account_key" {
  description = "Primary storage account key"
  value       = azurerm_storage_account.insecure_storage.primary_access_key # ⚠️ VULNERÁVEL - Expondo chave de acesso
  sensitive   = false
}

output "public_ip_address" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.insecure_public_ip.ip_address # ⚠️ VULNERÁVEL - Expondo IP público
}
