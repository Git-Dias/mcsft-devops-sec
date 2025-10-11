# ⚠️ VULNERABILIDADE: Arquivo .tfvars com secrets
admin_password      = "MyProductionPassword123!"
sql_admin_password  = "SQLProdPass456!"
storage_account_name = "prodstorage789"

# ⚠️ VULNERABILIDADE: Credenciais de provider hardcoded (em um cenário real)
subscription_id     = "12345678-1234-1234-1234-123456789012"
client_id           = "abcdefab-1234-1234-1234-123456789012"
client_secret       = "MyClientSecret123!" # ⚠️ VULNERÁVEL CRÍTICA
tenant_id           = "98765432-1234-1234-1234-123456789012"
