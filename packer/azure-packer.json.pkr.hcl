variable "subscription_id" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type    = string
  default = ""
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "The region in which to launch the instance."
}

variable "resource_group_name" {
  type        = string
  default     = "opendax"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "azure-arm" "opendax" {
  managed_image_name = "opendax-${local.timestamp}"
  managed_image_resource_group_name = "${var.resource_group_name}"
  subscription_id = "${var.subscription_id}"
  tenant_id = "${var.tenant_id}"

  os_type = "Linux"
  image_publisher = "Debian"
  image_offer = "debian-10"
  image_sku = "10-gen2"

  azure_tags = {
    app = "opendax"
  }

  location = "${var.location}"
  temp_compute_name = "opendax-build-${local.timestamp}"
  temp_resource_group_name = "opendax-temp-${local.timestamp}"
  vm_size = "Standard_DC4s_v2"

  ssh_username  = "deploy"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.azure-arm.opendax"]

  provisioner "shell" {
    script = "./packer/scripts/install-base.sh"
  }
  provisioner "shell" {
    inline = ["sudo newgrp docker"]
  }
  provisioner "shell-local" {
    inline = ["cp -r `ls -A | grep -v opendax | grep -v packer` ./opendax"]
  }
  provisioner "file" {
    destination = "/tmp"
    source      = "./opendax"
  }
  provisioner "shell-local" {
    inline = ["rm -rf ./opendax", "mkdir opendax", "touch ./opendax/.gitkeep"]
  }
  provisioner "shell" {
    inline = ["sudo chown -R deploy: /tmp/opendax", "sudo mv /tmp/opendax /home/deploy"]
  }
  provisioner "shell" {
    inline = ["sudo chown -R deploy: /home/deploy"]
  }
  provisioner "shell" {
    scripts = ["./packer/scripts/install-ruby.sh", "./packer/scripts/install-opendax.sh"]
  }
}
