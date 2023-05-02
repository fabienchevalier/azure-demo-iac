source "azure-arm" "glpi-image-base" {
  azure_tags = {
    dept = "QA"
    task = "Image deployment"
  }
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  image_offer                       = "debian-11"
  image_publisher                   = "Debian"
  image_sku                         = "11-backports-gen2"
  location                          = var.location
  managed_image_name                = "glpi-image-base"
  managed_image_resource_group_name = var.rg
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.glpi-image-base"]

  provisioner "ansible" {
    playbook_file = "ansible/maleo-glpi-image-base.yml"

  }
}