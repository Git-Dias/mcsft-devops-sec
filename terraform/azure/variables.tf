# VULNERABILIDADE: Variáveis com valores default inseguros
variable "admin_password" {
  description = "Virtual Machine administrator password"
  type        = string
  sensitive   = false # ⚠️ VULNERÁVEL - Não marcado como sensitive
  default     = "Admin123!" # ⚠️ VULNERÁVEL - Senha fraca e hardcoded
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  default     = "SQLAdmin123!" # ⚠️ VULNERÁVEL - Senha fraca
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
  default     = "insecurestorage789" # ⚠️ VULNERÁVEL - Nome pode vazar informações
}

# ⚠️ VULNERABILIDADE: Variáveis sem validation blocks
variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {} # ⚠️ VULNERÁVEL - Sem tags padrão
}
