# Terraform module azurerm-nocode-webserver

Provisions an Azure resource group and VNet containing a webserver VM and sample HashiCafe website, using a base image registered in [HCP Packer](https://www.hashicorp.com/products/packer).

Enabled for Terraform Cloud [no-code provisioning](https://developer.hashicorp.com/terraform/cloud-docs/no-code-provisioning/module-design).

## Prerequisites

For no-code provisioning, Azure credentials must be supplied to the workspace via environment variables (e.g. `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_CLIENT_ID`, and `ARM_CLIENT_SECRET` for a [service principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)). It is recommended to attach these via a project.

Also requires environment variables containing an HCP service principal credential (`HCP_CLIENT_ID` and `HCP_CLIENT_SECRET`). It is recommende to attach these globally or to projects where no-code workspaces will be provisioned.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_hcp"></a> [hcp](#requirement\_hcp) | ~> 0.82 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |
| <a name="provider_hcp"></a> [hcp](#provider\_hcp) | ~> 0.82 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.1 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.hashiapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.hashiapp-nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.hashiapp-nic-sg-assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.hashiapp-sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.hashiapp-pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.myresourcegroup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [null_resource.configure-web-app](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_integer.product](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [hcp_packer_artifact.ubuntu-webserver](https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/data-sources/packer_artifact) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Administrator password for OS. | `string` | `"Password123!"` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Administrator user name for OS. | `string` | `"hashicorp"` | no |
| <a name="input_department"></a> [department](#input\_department) | Value for the department tag. | `string` | `"WebDev"` | no |
| <a name="input_env"></a> [env](#input\_env) | Value for the environment tag. | `string` | n/a | yes |
| <a name="input_hashi_products"></a> [hashi\_products](#input\_hashi\_products) | n/a | <pre>list(object({<br>    name       = string<br>    color      = string<br>    image_file = string<br>  }))</pre> | <pre>[<br>  {<br>    "color": "#dc477d",<br>    "image_file": "hashicafe_art_consul.png",<br>    "name": "Consul"<br>  },<br>  {<br>    "color": "#ffffff",<br>    "image_file": "hashicafe_art_hcp.png",<br>    "name": "HCP"<br>  },<br>  {<br>    "color": "#60dea9",<br>    "image_file": "hashicafe_art_nomad.png",<br>    "name": "Nomad"<br>  },<br>  {<br>    "color": "#63d0ff",<br>    "image_file": "hashicafe_art_packer.png",<br>    "name": "Packer"<br>  },<br>  {<br>    "color": "#844fba",<br>    "image_file": "hashicafe_art_terraform.png",<br>    "name": "Terraform"<br>  },<br>  {<br>    "color": "#2e71e5",<br>    "image_file": "hashicafe_art_vagrant.png",<br>    "name": "Vagrant"<br>  },<br>  {<br>    "color": "#ffec6e",<br>    "image_file": "hashicafe_art_vault.png",<br>    "name": "Vault"<br>  }<br>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | The region where the virtual network is created. | `string` | n/a | yes |
| <a name="input_packer_bucket"></a> [packer\_bucket](#input\_packer\_bucket) | HCP Packer image bucket name. | `string` | `"ubuntu22-nginx"` | no |
| <a name="input_packer_channel"></a> [packer\_channel](#input\_packer\_channel) | HCP Packer image channel. | `string` | `"production"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | This prefix will be included in the name of most resources. | `string` | n/a | yes |
| <a name="input_subnet_prefix"></a> [subnet\_prefix](#input\_subnet\_prefix) | The address prefix to use for the subnet. | `string` | `"10.0.10.0/24"` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Specifies the size of the virtual machine. | `string` | `"Standard_B2s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_base_image"></a> [base\_image](#output\_base\_image) | n/a |
| <a name="output_hashiapp_url"></a> [hashiapp\_url](#output\_hashiapp\_url) | n/a |
| <a name="output_product"></a> [product](#output\_product) | The product which was randomly selected. |
<!-- END_TF_DOCS -->