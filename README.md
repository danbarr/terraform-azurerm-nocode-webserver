# Terraform module azurerm-nocode-webserver

Provisions a simple nginx webserver VM with sample HashiCafe website in Azure, using a base image registered in [HCP Packer](https://cloud.hashicorp.com/products/packer).

Enabled for Terraform Cloud [no-code provisioning](https://developer.hashicorp.com/terraform/cloud-docs/no-code-provisioning/module-design).

For no-code provisioning, Azure credentials must be supplied to the workspace via environment variables (e.g. `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_CLIENT_ID`, and `ARM_CLIENT_SECRET` for a [service principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)). Also requires HCP connection credentials, (`HCP_CLIENT_ID` and `HCP_CLIENT_SECRET`).
