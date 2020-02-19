# Creating a resource group
resource "azurerm_resource_group" "terraformgroup" {
    name     = "tfResourceGroup"
    location = "West Europe"

    tags = {
        environment = "challenge-app"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "terraformnetwork" {
    name                = "tfVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "West Europe"
    resource_group_name = azurerm_resource_group.terraformgroup.name

    tags = {
        environment = "challenge-app"
    }
}

# Create subnet
resource "azurerm_subnet" "terraformsubnet" {
    name                 = "tfSubnet"
    resource_group_name  = azurerm_resource_group.terraformgroup.name
    virtual_network_name = azurerm_virtual_network.terraformnetwork.name
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "terraformpublicip" {
    name                         = "tfPublicIP"
    location                     = "West Europe"
    resource_group_name          = azurerm_resource_group.terraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "challenge-app"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraformnsg" {
    name                = "tfNetworkSecurityGroup"
    location            = "West Europe"
    resource_group_name = azurerm_resource_group.terraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "challenge-app"
    }
}

# Creating network interface
resource "azurerm_network_interface" "terraformnic" {
    name                      = "tfNIC"
    location                  = "West Europe"
    resource_group_name       = azurerm_resource_group.terraformgroup.name
    network_security_group_id = azurerm_network_security_group.terraformnsg.id

    ip_configuration {
        name                          = "tfNicConfiguration"
        subnet_id                     = azurerm_subnet.terraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.terraformpublicip.id
    }

    tags = {
        environment = "challenge-app"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.terraformgroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "tfstorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.terraformgroup.name
    location                    = "West Europe"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "challenge-app"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "terraformvm" {
    name                  = "VM"
    location              = "West Europe"
    resource_group_name   = azurerm_resource_group.terraformgroup.name
    network_interface_ids = [azurerm_network_interface.terraformnic.id]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "tfOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "vm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = var.ssh_pub_key
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.tfstorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "challenge-app"
    }
}