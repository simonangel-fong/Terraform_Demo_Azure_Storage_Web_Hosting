# az_rg.tf

resource "azurerm_resource_group" "main" {
  name     = local.name
  location = local.location
  tags     = local.default_tags
}

