# db-s-2vcpu-4gb
resource "digitalocean_database_cluster" "opendax" {
  name       = "opendax-pro-${random_id.opendax.hex}"
  engine     = "mysql"
  size       = "${var.db_machine_type}"
  region     = "${var.region}"
  node_count = 1
}
