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
  default     = "vnet_vm"
}

variable "vnet_func_app_name" {
  description = "Name of vnet function app"
  default     = "vnet_function_app"
}
