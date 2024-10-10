terraform {
  required_providers {

    azurerm = {
      
      source  = "hashicorp/azurerm"
      version = ">=3.111.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">=3.6.2"
    }
  }
 
}

provider "azurerm" {
  features {

  }
  subscription_id =  "10d377a9-0a75-40af-b0ce-fbca0bed2382"
}