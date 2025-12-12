# VULNERABILIDADE: Variaveis com valores default inseguros
variable "admin_password" {
  description = "Virtual Machine administrator password"
  type        = string
  sensitive   = false # VULNERAVEL - Nao marcado como sensitive
  default     = "Admin123!" # VULNERAVEL - Senha fraca e hardcoded
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  default     = "SQLAdmin123!" # VULNERAVEL - Senha fraca
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
  default     = "insecurestorage789" # VULNERAVEL - Nome pode vazar informacoes
}

# VULNERABILIDADE: Variaveis sem validation blocks
variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {} # VULNERAVEL - Sem tags padrao
}
