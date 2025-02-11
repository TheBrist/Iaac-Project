terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.18.0"
    }
    google = {
        source = "hashicorp/google"
        version = "~> 6.19.0"
    }
  }
  
}
