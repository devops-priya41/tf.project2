output "cosmosdb_connectionstrings" {
  value = azurerm_cosmosdb_account.cosmosdb.connection_strings
   sensitive   = true
}