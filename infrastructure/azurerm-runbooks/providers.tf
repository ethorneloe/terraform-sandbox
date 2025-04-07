terraform {
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.4.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}