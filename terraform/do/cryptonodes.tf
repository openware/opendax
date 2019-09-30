# Bitcoind
resource "digitalocean_droplet" "bitcoind" {
  name         = "bitcoin-${random_id.opendax.hex}"
  size         = "${var.cryptonode_machine_type}"
  region       = "${var.region}"
  image        = "${var.bitcoind_image}"
}

resource "digitalocean_firewall" "bitcoind" {
  name = "opendax-pro-allow-bitcoind-${random_id.opendax.hex}"

  droplet_ids = ["${digitalocean_droplet.opendax.id}"]

  inbound_rule {
      protocol           = "tcp"
      port_range         = "${var.bitcoind_port}"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "${var.bitcoind_rpcport}"
      source_addresses   = ["${digitalocean_droplet.opendax.ipv4_address}"]
  }

  inbound_rule {
      protocol           = "icmp"
      source_addresses   = ["0.0.0.0/0", "::/0"]
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

# Parity
resource "digitalocean_droplet" "parity" {
  name         = "parity-${random_id.opendax.hex}"
  size         = "${var.cryptonode_machine_type}"
  region       = "${var.region}"
  image        = "${var.parity_image}"
}

resource "digitalocean_firewall" "parity" {
  name = "opendax-pro-allow-parity-${random_id.opendax.hex}"

  droplet_ids = ["${digitalocean_droplet.opendax.id}"]

  inbound_rule {
      protocol           = "tcp"
      port_range         = "${var.parity_port}"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "${var.parity_rpcport}"
      source_addresses   = ["${digitalocean_droplet.opendax.ipv4_address}"]
  }

  inbound_rule {
      protocol           = "icmp"
      source_addresses   = ["0.0.0.0/0", "::/0"]
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
