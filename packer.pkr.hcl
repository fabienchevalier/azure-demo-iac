# variable declaration
variable "client_id" {
  type    = string
}

variable "client_secret" {
  type    = string
}

variable "subscription_id" {
  type    = string
}

variable "tenant_id" {
  type    = string
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "azure-arm" "webserver-latest-vhd" {
  azure_tags = {
    company = "maleo"
    env     = "qa"
  }
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "Canonical"
  image_sku                         = "22_04-lts-gen2"
  location                          = "France Central"
  managed_image_name                = "webserver-image-latest"
  managed_image_resource_group_name = "packer-resource-group"
  os_type                           = "Linux"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  vm_size                           = "Standard_DS2_v2"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.azure-arm.webserver-latest-vhd"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y software-properties-common",
      "sudo apt-add-repository -y ppa:ansible/ansible",
      "sudo apt-get update",
      "sudo apt-get install -y ansible",
      "ansible-galaxy install geerlingguy.apache"
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "ansible/maleo-webserver-image-base.yml"
    playbook_dir  = "ansible"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}