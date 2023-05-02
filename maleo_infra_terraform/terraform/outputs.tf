output "mysql_server_fqdn" {
  description = "Name of the Azure SQL Database created."
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}