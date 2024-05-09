provider "azurerm" {
  features {}
}

variable "prefix" {
  default = "ibm"
}

locals {
  vm_name = "${var.prefix}-vm"
}

resource "azurerm_resource_group" "ibm-rg" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "ibm_network" {
  name                = "${var.prefix}-network"
  resource_group_name = azurerm_resource_group.ibm-rg.name
  location            = azurerm_resource_group.ibm-rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "ibm_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.ibm-rg.name
  virtual_network_name = azurerm_virtual_network.ibm_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "ibm_nic" {
  name                = "ibm-nic"
  location            = azurerm_resource_group.ibm-rg.location
  resource_group_name = azurerm_resource_group.ibm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ibm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ibm_ip.id
  }
}

resource "azurerm_public_ip" "ibm_ip" {
  name                = "ibm_ip"
  location            = azurerm_resource_group.ibm-rg.location
  resource_group_name = azurerm_resource_group.ibm-rg.name
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "ibm-vm" {
  name                  = "ibm-vm"
  resource_group_name   = azurerm_resource_group.ibm-rg.name
  location              = azurerm_resource_group.ibm-rg.location
  size                  = "Standard_F4s_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.ibm_nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-confidential-vm-focal"
      sku       = "20_04-lts-cvm"
      version   = "20.04.202402050"
  }
}

resource "azurerm_managed_disk" "ibm-managed-disk" {
  name                 = "${local.vm_name}-disk1"
  location             = azurerm_resource_group.ibm-rg.location
  resource_group_name  = azurerm_resource_group.ibm-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.ibm-managed-disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.ibm-vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

# resource "local_file" "ansible_inventory" {
#   content  = azurerm_public_ip.ibm_ip.ip_address
#   filename = "${path.module}/inventory.ini"
#   depends_on = [azurerm_linux_virtual_machine.ibm-vm]
# }

resource "azurerm_storage_account" "ibm_sa" {
  name                     = "${var.prefix}storageaccount88"
  resource_group_name      = azurerm_resource_group.ibm-rg.name
  location                 = azurerm_resource_group.ibm-rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "poc"
  }
}

resource "azurerm_storage_share" "ibm_share" {
  name                 = "ibmfileshare"
  storage_account_name = azurerm_storage_account.ibm_sa.name
  quota                = 50
}

output "public_ip" {
  value = azurerm_public_ip.ibm_ip.ip_address
}