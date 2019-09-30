resource "random_id" "opendax" {
  byte_length = 2
}

resource "digitalocean_ssh_key" "opendax" {
  name       = "OpenDAX Provisioner Key ${random_id.opendax.hex}"
  public_key = "${file("${var.ssh_public_key}")}"
}

resource "digitalocean_droplet" "opendax" {
  name         = "${var.instance_name}-${random_id.opendax.hex}"
  size         = "${var.core_machine_type}"
  region       = "${var.region}"
  image        = "${var.core_image}"
  ssh_keys     = ["${digitalocean_ssh_key.opendax.fingerprint}"]

  provisioner "local-exec" {
    command = "mkdir -p /tmp/upload && rsync -rv --exclude=terraform ../ /tmp/upload/"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/opendax"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }
  }

  provisioner "file" {
    source      = "/tmp/upload/"
    destination = "/home/${var.ssh_user}/opendax"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }
  }

  provisioner "remote-exec" {
    script = "../bin/install.sh"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }
  }

  provisioner "remote-exec" {
    script = "../bin/start.sh"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }
  }
}

resource "digitalocean_firewall" "opendax" {
  name = "opendax-pro-${random_id.opendax.hex}"

  droplet_ids = ["${digitalocean_droplet.opendax.id}"]

  inbound_rule {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "80"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "443"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "icmp"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
      protocol                = "tcp"
      port_range              = "53"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
      protocol                = "udp"
      port_range              = "53"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
      protocol                = "icmp"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
}
