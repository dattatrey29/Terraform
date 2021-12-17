
variable "rg_name" {
  description = "Name of Resource Group"
  type = list(string)
  default = [ "rg-3", "rg-4" ]
}

variable "vnet_name"{
    description = "Name of vnet"
    type = list(string)
    default = [ "vn-1", "vnet-2" ]
}

variable "location" {
  description = "Locations"
  type = list(string)
  default = [ "centralindia", "westeurope" ]
}

variable "address" {
    description = "address value"
    type = list(string)
    default = [ "10.0.0.0/16", "10.2.0.0/16" ]
}

variable "subnet" {
  description = "subnet details"
  type = list(string)
  default = [ "10.0.0.0/27", "10.1.0.0/27" ]
}

variable "vm_name" {
    description = "Virtual Machine name"
    type = list(string)
    default = [ "vm-1", "vm-2" ]
}

variable "storage_name" {
    description = "Storage name"
    type = list(string)
    default = [ "demodssstg1dt", "demodssstg2dt" ]
}


