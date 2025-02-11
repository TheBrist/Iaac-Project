provider "azurerm" {
  features {}
  subscription_id = "cb6a7a77-cdd1-4d79-974a-d6917ccb4ff7"
}

locals {
  vnets = {
    "${var.vnet_vm_name}" = {
      address_space = ["10.0.0.0/16"]
    }

    "${var.vnet_func_app_name}" = {
      address_space = ["10.1.0.0/16"]
    }
  }

  subnets = {
    "subnet-vm" = {
      address = "10.0.0.0/24"
      vnet_name = "${var.vnet_vm_name}"
    }
    "AzureBastionSubnet" = {
      address = "10.0.1.0/26"
      vnet_name = "${var.vnet_vm_name}"
    }
    "subnet-function-app" = {
      address = "10.1.0.0/24"
      vnet_name = "${var.vnet_func_app_name}"
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

resource "azurerm_subnet" "subnet" {
  for_each = local.subnets
  name = each.key
  resource_group_name = var.resource_group_name
  virtual_network_name = each.value.vnet_name
  address_prefixes = [ each.value.address ]

  depends_on = [ azurerm_virtual_network.vnets ]
}

resource "azurerm_virtual_network" "vnets" {
  for_each            = local.vnets
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = each.value.address_space
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each                     = local.peerings
  name                         = each.key
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnets[each.value.vnet_name].name
  remote_virtual_network_id    = azurerm_virtual_network.vnets[each.value.remote_name].id
  allow_virtual_network_access = true

  depends_on = [azurerm_virtual_network.vnets]
}

resource "azurerm_network_security_group" "nsg_vm" {
  name                = "nsg-vm"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-RDP-from-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = local.subnets["AzureBastionSubnet"].address
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "Deny-All"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  ip_configuration {
    private_ip_address_allocation = "Dynamic"
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet["subnet-vm"].id
  }
}

resource "azurerm_network_interface_security_group_association" "add_nsg_to_vm_nic" {
  network_interface_id = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_vm.id
}

resource "azurerm_role_assignment" "vm_rdp_access" {
  principal_id         = var.user_principal_id
  role_definition_name = "Virtual Machine Administrator Login"
  scope                = azurerm_virtual_machine.vm.id
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-windows"
  resource_group_name   = var.resource_group_name
  location              = var.location
  vm_size               = "Standard_B1ms"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  storage_os_disk {
    name          = "os-disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "niger"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {}
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
}

resource "azurerm_public_ip" "bastion_public_ip" {
  name = "bastion-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name = "bastion-host"
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name = "config"
    subnet_id = azurerm_subnet.subnet["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}