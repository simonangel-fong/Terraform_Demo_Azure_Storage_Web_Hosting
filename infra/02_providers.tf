# providers.tf

# ##############################
# Version
# ##############################
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Backend config
  backend "azurerm" {}
}

# ##############################
# Providers
# ##############################
# Azure
provider "azurerm" {
  features {}
}
