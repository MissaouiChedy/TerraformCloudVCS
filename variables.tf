variable "resource_group_location" {
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg-chedy"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "virtual_machine_name" {
  default     = "KABLAM0001"
  description = "Name Of the Virtual Machine"
}

variable "virtual_machine_username" {
  description = "Name Of the first user of the Virtual Machine"
  default     = "chedy"
}

variable "virtual_machine_password" {
  description = "Password for the virtual Machine User"
  sensitive   = true
}
