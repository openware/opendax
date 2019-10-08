output opendax_ip {
  value = "${google_compute_address.opendax.address}"
}

output parity_ip {
  value = "${google_compute_address.parity.address}"
}

output bitcoind_ip {
  value = "${google_compute_address.bitcoind.address}"
}

output db_address {
  description = "The IPv4 address of the master database instnace"
  value       = "${google_sql_database_instance.master.ip_address.0.ip_address}"
}

output generated_root_user_password {
  description = "The auto generated Cloud SQL root user password"
  value       = "${random_id.root-user-password.hex}"
  sensitive   = true
}
