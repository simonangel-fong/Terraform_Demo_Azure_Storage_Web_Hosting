# az_data.tf

data "azurerm_resource_group" "main" {
  name = local.name
}
