terraform {

  required_providers {
   azurerm = {
       source = "hashicorp/azurerm"
       version = "~>2.0"
   }
  }
}

provider "azurerm" {
   features {
     
   }
}

resource "azurerm_resource_group" "app" {
    count = length(var.rg_name)
    name = var.rg_name[count.index]
    location = var.location[count.index]
}

 resource "azurerm_storage_account" "name" {
   count = length(var.storage_name)
   name = var.storage_name[count.index]
   resource_group_name = azurerm_resource_group.app[count.index].name
   location = azurerm_resource_group.app[count.index].location
   account_tier = "Standard"
   account_replication_type = "LRS"
 }

  resource "azurerm_virtual_network" "vnet" {
   count = length(var.vnet_name)
   name = var.vnet_name[count.index]
   location = azurerm_resource_group.app[count.index].location
   resource_group_name = azurerm_resource_group.app[count.index].name
  address_space       = [element(var.address, count.index)]
 }

  
 resource "azurerm_subnet" "name" {
   #for_each = azurerm_virtual_network.vnet.name
   count = length(var.vnet_name)
   name = "subnet-${count.index}_"
   resource_group_name = azurerm_resource_group.app[count.index].name
   virtual_network_name = azurerm_virtual_network.vnet[count.index].name
  address_prefix = cidrsubnet(
    element(
      azurerm_virtual_network.vnet[count.index].address_space,
      count.index,
    ),
    13,
    0,
  ) 
}

 resource "azurerm_network_interface" "nic" {
   count = length(var.vm_name)
   name = "nicdt"
   resource_group_name = azurerm_resource_group.app[count.index].name
   location = azurerm_resource_group.app[count.index].location

   ip_configuration {
     
     name = "ipconfig"
     subnet_id = azurerm_subnet.name[count.index].id
     private_ip_address_allocation = "Dynamic"
   }
 }

 resource "azurerm_virtual_machine" "name" {
   count = length(var.vm_name)
   name = var.vm_name[count.index]
   resource_group_name = azurerm_resource_group.app[count.index].name
   location = azurerm_resource_group.app[count.index].location
   network_interface_ids = [azurerm_network_interface.nic[count.index].id]
   vm_size = "Standard_DS1_v2"
   delete_os_disk_on_termination = "true"
   delete_data_disks_on_termination = "true"

   storage_image_reference {
     publisher = "OpenLogic"
     offer = "CentOS"
     sku = "7.7"
     version = "Latest" 
   }

   storage_os_disk {
     name          = "osdisk"
     create_option = "FromImage"
     caching = "ReadWrite"
     managed_disk_type = "Standard_LRS"
   }

 
   os_profile {
     computer_name = "cname ${count.index}"
     admin_username = "${count.index}-adm"
     admin_password = "dattatrey29@"
   }

   os_profile_linux_config {
     disable_password_authentication = false
   }
  
 }

 resource "azurerm_virtual_network_peering" "peering" {
   count = length(var.location)
   name                         = "peering-to-${element(azurerm_virtual_network.vnet.*.name, 1 - count.index)}"
  resource_group_name          = element(azurerm_resource_group.app.*.name, count.index)
  virtual_network_name         = element(azurerm_virtual_network.vnet.*.name, count.index)
  remote_virtual_network_id    = element(azurerm_virtual_network.vnet.*.id, 1 - count.index)
   allow_virtual_network_access = true
   allow_forwarded_traffic = true
   allow_gateway_transit = false
 }

