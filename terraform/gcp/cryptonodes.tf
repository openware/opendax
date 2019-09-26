# Bitcoind

resource "google_compute_address" "bitcoind" {
  name = "bitcoind-ip-${random_id.opendax.hex}"
}

resource "google_compute_instance" "bitcoind" {
  name         = "bitcoind-${random_id.opendax.hex}"
  machine_type = "${var.cryptonode_machine_type}"
  zone         = "${var.zone}"

  allow_stopping_for_update = true

  tags = ["allow-bastion-ssh","http-server", "https-server", "bitcoind-node-${random_id.opendax.hex}","bitcoind-node-${random_id.opendax.hex}-sync"]

  deletion_protection = "true"

  boot_disk {
    auto_delete = "false"

    initialize_params {
      image = "${var.bitcoind_image}"
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "${var.network_name}"
    subnetwork = "${var.subnetwork_name}"

    access_config {
      nat_ip = "${google_compute_address.bitcoind.address}"
    }
  }
}

resource "google_compute_firewall" "allow_bitcoind_rpc" {
  name    = "allow-bitcoind-${random_id.opendax.hex}-rpc"
  network = "${var.network_name}"

  source_ranges = ["${google_compute_address.opendax.address}"]
  target_tags   = ["bitcoind-node-${random_id.opendax.hex}"]

  allow {
    protocol = "tcp"
    ports    = ["${var.bitcoind_rpcport}"]
  }
}

resource "google_compute_firewall" "allow_bitcoind_sync" {
  name    = "allow-bitcoind-${random_id.opendax.hex}-sync"
  network = "${var.network_name}"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bitcoind-node-${random_id.opendax.hex}-sync"]

  allow {
    protocol = "tcp"
    ports    = ["${var.bitcoind_port}"]
  }
}

# Parity

resource "google_compute_address" "parity" {
  name = "parity-ip-${random_id.opendax.hex}"
}

resource "google_compute_instance" "parity" {
  name         = "parity-${random_id.opendax.hex}"
  machine_type = "${var.cryptonode_machine_type}"
  zone         = "${var.zone}"

  allow_stopping_for_update = true

  tags = ["allow-bastion-ssh","http-server", "https-server", "parity-node-${random_id.opendax.hex}","parity-node-${random_id.opendax.hex}-sync"]

  deletion_protection = "true"

  boot_disk {
    auto_delete = "false"

    initialize_params {
      image = "${var.parity_image}"
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "${var.network_name}"
    subnetwork = "${var.subnetwork_name}"

    access_config {
      nat_ip = "${google_compute_address.parity.address}"
    }
  }
}

resource "google_compute_firewall" "allow_parity_rpc" {
  name    = "allow-parity-${random_id.opendax.hex}-rpc"
  network = "${var.network_name}"

  source_ranges = ["${google_compute_address.opendax.address}"]
  target_tags   = ["parity-node-${random_id.opendax.hex}"]

  allow {
    protocol = "tcp"
    ports    = ["${var.parity_rpcport}"]
  }
}

resource "google_compute_firewall" "allow_parity_sync" {
  name    = "allow-parity-${random_id.opendax.hex}-sync"
  network = "${var.network_name}"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["parity-node-${random_id.opendax.hex}-sync"]

  allow {
    protocol = "tcp"
    ports    = ["${var.parity_port}"]
  }
}
