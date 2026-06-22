# az_storage.tf

# ##############################
# AZ Storage Account
# ##############################
resource "azurerm_storage_account" "web" {
  name                = local.storage_sa_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = true

  tags = local.default_tags
}

resource "azurerm_storage_account_static_website" "web" {
  storage_account_id = azurerm_storage_account.web.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

# ##############################
# Upload Files
# ##############################
locals {
  web_root = "${path.module}/../web"

  web_files = fileset(local.web_root, "**")

  content_types = {
    html  = "text/html"
    htm   = "text/html"
    css   = "text/css"
    js    = "application/javascript"
    json  = "application/json"
    svg   = "image/svg+xml"
    png   = "image/png"
    jpg   = "image/jpeg"
    jpeg  = "image/jpeg"
    gif   = "image/gif"
    ico   = "image/x-icon"
    txt   = "text/plain"
    xml   = "application/xml"
    woff  = "font/woff"
    woff2 = "font/woff2"
  }
}

data "azurerm_storage_container" "web" {
  name               = "$web"
  storage_account_id = azurerm_storage_account.web.id

  depends_on = [azurerm_storage_account_static_website.web]
}

resource "azurerm_storage_blob" "web" {
  for_each = local.web_files

  name                 = each.value
  storage_container_id = data.azurerm_storage_container.web.id
  type                 = "Block"
  source               = "${local.web_root}/${each.value}"
  content_type         = lookup(local.content_types, lower(reverse(split(".", each.value))[0]), "application/octet-stream")
  content_md5          = filemd5("${local.web_root}/${each.value}")
}
