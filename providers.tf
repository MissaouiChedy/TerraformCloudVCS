terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
  cloud {
    organization = "OrgOfChedy"

    workspaces {
      name = "upp-vmm-westeurope-dev"
    }
  }
}

provider "azurerm" {
  features {}
}
