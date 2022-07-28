data "azurerm_client_config" "current" {   
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RG" {
  name     = var.pk_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_key_vault" "keyvault1" {
  name                       = "priyakeyvault2"
  location                   = azurerm_resource_group.RG.location
  resource_group_name        = azurerm_resource_group.RG.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "tfex-cosmos-db1"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.RG.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

 # geo_location {
 #   location          = "eastus"
 #   failover_priority = 1
 # }

  geo_location {
    location          = "eastus"
    failover_priority = 0
  }


}

resource "azurerm_key_vault_secret" "secretkey" { 
  name         = "CosmosDBConnectionString"
  value        = tostring("${azurerm_cosmosdb_account.cosmosdb.connection_strings[0]}")
  key_vault_id = azurerm_key_vault.keyvault1.id

}