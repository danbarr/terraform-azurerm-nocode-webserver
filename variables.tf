variable "prefix" {
  type        = string
  description = "This prefix will be included in the name of most resources."
}

variable "location" {
  type        = string
  description = "The region where the virtual network is created."
}

variable "env" {
  type        = string
  description = "Value for the environment tag."
}

variable "department" {
  type        = string
  description = "Value for the department tag."
  default     = "WebDev"
}

variable "address_space" {
  type        = string
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  type        = string
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "vm_size" {
  type        = string
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B2s"
}

variable "packer_bucket" {
  type        = string
  description = "HCP Packer image bucket name."
  default     = "ubuntu22-nginx"
}

variable "packer_channel" {
  type        = string
  description = "HCP Packer image channel."
  default     = "production"
}

variable "admin_username" {
  type        = string
  description = "Administrator user name for OS."
  default     = "hashicorp"
}

variable "admin_password" {
  type        = string
  description = "Administrator password for OS."
  default     = "Password123!"
}

variable "hashi_products" {
  type = list(object({
    name       = string
    color      = string
    image_file = string
  }))
  default = [
    {
      name       = "Consul"
      color      = "#dc477d"
      image_file = "hashicafe_art_consul.png"
    },
    {
      name       = "HCP"
      color      = "#ffffff"
      image_file = "hashicafe_art_hcp.png"
    },
    {
      name       = "Nomad"
      color      = "#60dea9"
      image_file = "hashicafe_art_nomad.png"
    },
    {
      name       = "Packer"
      color      = "#63d0ff"
      image_file = "hashicafe_art_packer.png"
    },
    {
      name       = "Terraform"
      color      = "#844fba"
      image_file = "hashicafe_art_terraform.png"
    },
    {
      name       = "Vagrant"
      color      = "#2e71e5"
      image_file = "hashicafe_art_vagrant.png"
    },
    {
      name       = "Vault"
      color      = "#ffec6e"
      image_file = "hashicafe_art_vault.png"
    }
  ]
}
