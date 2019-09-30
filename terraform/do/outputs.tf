output opendax_ip {
  value = "${digitalocean_droplet.opendax.ipv4_address}"
}

output parity_ip {
  value = "${digitalocean_droplet.parity.ipv4_address}"
}

output bitcoind_ip {
  value = "${digitalocean_droplet.parity.ipv4_address}"
}

output db_address {
  value = "${digitalocean_database_cluster.opendax.uri}"
}

output db_user {
  value = "${digitalocean_database_cluster.opendax.user}"
}

output db_password {
  value = "${digitalocean_database_cluster.opendax.password}"
}
