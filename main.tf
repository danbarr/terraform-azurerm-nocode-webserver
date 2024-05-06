terraform {
  required_version = ">= 1.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.82"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  timestamp = timestamp()

  common_tags = {
    environment = var.env
    department  = var.department
    application = "HashiCafe website"
  }
}

resource "random_integer" "product" {
  min = 0
  max = length(var.hashi_products) - 1
  keepers = {
    "timestamp" = local.timestamp
  }
}

data "hcp_packer_artifact" "ubuntu-webserver" {
  bucket_name  = var.packer_bucket
  channel_name = var.packer_channel
  platform     = "azure"
  region       = var.location
}

resource "azurerm_resource_group" "myresourcegroup" {
  name     = "${var.prefix}-demo-webapp"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.myresourcegroup.location
  address_space       = [var.address_space]
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.myresourcegroup.name
  address_prefixes     = [var.subnet_prefix]
}

resource "azurerm_network_security_group" "hashiapp-sg" {
  name                = "${var.prefix}-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  tags                = local.common_tags

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "hashiapp-nic" {
  name                = "${var.prefix}-hashiapp-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hashiapp-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "hashiapp-nic-sg-assoc" {
  network_interface_id      = azurerm_network_interface.hashiapp-nic.id
  network_security_group_id = azurerm_network_security_group.hashiapp-sg.id
}

resource "azurerm_public_ip" "hashiapp-pip" {
  name                = "${var.prefix}-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-app"
  tags                = local.common_tags

  lifecycle {
    postcondition {
      condition     = self.fqdn != ""
      error_message = "The public IP failed to assign an FQDN."
    }
  }
}

resource "azurerm_linux_virtual_machine" "hashiapp" {
  name                  = "${var.prefix}-app"
  location              = var.location
  resource_group_name   = azurerm_resource_group.myresourcegroup.name
  size                  = var.vm_size
  source_image_id       = data.hcp_packer_artifact.ubuntu-webserver.external_identifier
  network_interface_ids = [azurerm_network_interface.hashiapp-nic.id]
  tags                  = local.common_tags

  os_disk {
    name                 = "${var.prefix}-osdisk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  computer_name                   = var.prefix
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = base64encode(<<-EOF
    #!/bin/bash

    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
    apt-get -qy update
    apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install nginx
    systemctl enable nginx --now
    ufw allow http
    mkdir -p /var/www/html/img
    chown -R ${var.admin_username} /var/www/html
  EOF
  )

  # Added to allow destroy to work correctly.
  depends_on = [azurerm_network_interface_security_group_association.hashiapp-nic-sg-assoc]

  lifecycle {
    precondition {
      condition     = data.hcp_packer_artifact.ubuntu-webserver.region == var.location
      error_message = "The selected image must be in the same region as the deployed resources."
    }

    postcondition {
      condition     = self.source_image_id == data.hcp_packer_artifact.ubuntu-webserver.external_identifier
      error_message = "A newer source image is available in the HCP Packer channel, please re-deploy."
    }

    postcondition {
      condition     = self.os_disk[0].disk_size_gb >= 10 && self.os_disk[0].disk_size_gb < 100
      error_message = "The OS disk must be at least 10GB and less than 100GB."
    }
  }
}

# We're using a little trick here so we can run the provisioner without
# destroying the VM. Do not do this in production.

resource "null_resource" "configure-web-app" {
  depends_on = [azurerm_linux_virtual_machine.hashiapp]

  triggers = {
    build_number = local.timestamp
  }

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_public_ip.hashiapp-pip.fqdn
  }

  provisioner "remote-exec" {
    # We need to wait for cloud-init to finish so permissions are correct.
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/index.html", {
      product_name  = var.hashi_products[random_integer.product.result].name
      product_color = var.hashi_products[random_integer.product.result].color
      product_image = var.hashi_products[random_integer.product.result].image_file
    })
    destination = "/var/www/html/index.html"
  }

  provisioner "file" {
    source      = "${path.module}/files/img/"
    destination = "/var/www/html/img"
  }
}
