variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "resource_group_location" {
  type        = string
  description = "Resource Group Location"
}

variable "virtual_network_name" {
  type        = string
  description = "VNet name"
}

variable "subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "public_ip_name" {
  type        = string
  description = "Public IP name"
}

variable "network_security_group_name" {
  type        = string
  description = "NSG name"
}

variable "network_interface_name" {
  type        = string
  description = "NIC name"
}

variable "linux_virtual_machine_name" {
  type        = string
  description = "VM name"
}