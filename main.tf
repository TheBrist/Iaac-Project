provider "azurerm" {
  features {}
  subscription_id = "cb6a7a77-cdd1-4d79-974a-d6917ccb4ff7"
}

locals {
  vnets = {
    "${var.vnet_vm_name}" = {
      address_space = ["10.0.0.0/16"]
      subnets = {
        "subnet-vm" = "10.0.0.0/24"
      }
    }

    "${var.vnet_func_app_name}" = {
      address_space = ["10.1.0.0/16"]
      subnets = {
        "subnet-function-app" = "10.1.0.0/24"
      }
    }
  }

  peerings = {
    "vm_to_function_app" = {
      vnet_name   = "${var.vnet_vm_name}"
      remote_name = "${var.vnet_func_app_name}"
    }
    "function_app_to_vm" = {
      vnet_name   = "${var.vnet_func_app_name}"
      remote_name = "${var.vnet_vm_name}"
    }
  }
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = local.vnets
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = each.value.address_space

  dynamic "subnet" {
    for_each = each.value.subnets
    content {
      name             = subnet.key
      address_prefixes = [subnet.value]
    }
  }
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = local.peerings
  name                         = each.key
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet[each.value.vnet_name].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet[each.value.remote_name].id
  allow_virtual_network_access = true

  depends_on = [azurerm_virtual_network.vnet]
}


