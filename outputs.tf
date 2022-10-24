output "hashiapp_url" {
  value = "http://${azurerm_public_ip.hashiapp-pip.fqdn}"
}

output "base_image" {
  value = data.hcp_packer_image.ubuntu-webserver.labels["managed_image_name"]
}

output "product" {
  description = "The product which was randomly selected."
  value       = var.hashi_products[random_integer.product.result].name
}
