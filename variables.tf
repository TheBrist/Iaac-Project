variable "resource_group_name" {
  description = "Resource group name"
  default     = "netanel"
}

variable "location" {
  description = "Location"
  default     = "Israel Central"
}

variable "vnet_vm_name" {
  description = "Name of vnet vm"
  default     = "vnet-vm"
}

variable "vnet_func_app_name" {
  description = "Name of vnet function app"
  default     = "vnet-function-app"
}

variable "user_principal_id" {
  description = "Allows access to VM via RDP"
  default = "db506c9c-457c-4d86-81dd-6e5b2670c7be"
}

variable "admin_username" {
  description = "Admin username"
  default = "oriram"
}

variable "admin_password" {
  description = "Admin password"
  default = "Homogadol123"
}