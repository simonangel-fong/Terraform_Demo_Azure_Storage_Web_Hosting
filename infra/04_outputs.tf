# outputs.tf

# output "resource_group_name" {
#   description = "Name of the resource group."
#   value       = azurerm_resource_group.this.name
# }

# output "storage_account_name" {
#   description = "Name of the storage account hosting the static site."
#   value       = azurerm_storage_account.web.name
# }

# output "primary_web_endpoint" {
#   description = "Public HTTPS endpoint of the static website."
#   value       = azurerm_storage_account.web.primary_web_endpoint
# }

# output "uploaded_files" {
#   description = "Files synced to the $web container."
#   value       = sort([for b in azurerm_storage_blob.web : b.name])
# }
