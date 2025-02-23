provider "azurerm" {
  features {}
  subscription_id = "cb6a7a77-cdd1-4d79-974a-d6917ccb4ff7"
}

provider "google" {
  alias   = "producer"
}
module "azure" {
  source = "./azure"
}

module "gcp" {
  source = "./gcp"
}
