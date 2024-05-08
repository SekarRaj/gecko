provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "microfocus-rg" {
  name     = "microfocus-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "microfocus_network" {
  name                = "microfocus-network"
  resource_group_name = azurerm_resource_group.microfocus-rg.name
  location            = azurerm_resource_group.microfocus-rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "microfocus_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.microfocus-rg.name
  virtual_network_name = azurerm_virtual_network.microfocus_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "microfocus_nic" {
  name                = "microfocus-nic"
  location            = azurerm_resource_group.microfocus-rg.location
  resource_group_name = azurerm_resource_group.microfocus-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.microfocus_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.microfocus_ip.id
  }
}

resource "azurerm_public_ip" "microfocus_ip" {
  name                = "microfocus_ip"
  location            = azurerm_resource_group.microfocus-rg.location
  resource_group_name = azurerm_resource_group.microfocus-rg.name
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "microfocus-vm" {
  name                  = "microfocus-vm"
  resource_group_name   = azurerm_resource_group.microfocus-rg.name
  location              = azurerm_resource_group.microfocus-rg.location
  size                  = "Standard_F4s_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.microfocus_nic.id]

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

  # provisioner "local-exec" {
  #   command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u adminuser ${local_file.ansible_playbook.filename}"
  # }
}

resource "local_file" "ansible_inventory" {
  content  = azurerm_public_ip.microfocus_ip.ip_address
  filename = "${path.module}/inventory.ini"
  depends_on = [azurerm_linux_virtual_machine.microfocus-vm]
}

# resource "local_file" "ansible_playbook" {
#   content = templatefile("${path.module}/ibm_cobol_playbook.tpl", { vm_ip = azurerm_public_ip.microfocus_ip.ip_address })
#   filename = "${path.module}/playbook.yml"
# }

output "public_ip" {
  value = azurerm_public_ip.microfocus_ip.ip_address
}