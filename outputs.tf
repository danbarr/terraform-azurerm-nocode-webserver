output "hashiapp_url" {
  value = "http://${azurerm_public_ip.hashiapp-pip.fqdn}"
}

output "base_image" {
  value = data.hcp_packer_image.ubuntu-webserver.labels["managed_image_name"]
}
