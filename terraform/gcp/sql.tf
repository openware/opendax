resource "google_sql_database_instance" "master" {
  name             = "${var.db_instance_name}"
  project          = "${var.project}"
  region           = "${var.region}"
  database_version = "${var.database_version}"

  settings {
    tier                        = "${var.db_machine_type}"
    activation_policy           = "${var.activation_policy}"
    authorized_gae_applications = ["${var.authorized_gae_applications}"]
    disk_autoresize             = "${var.disk_autoresize}"
    backup_configuration        = ["${var.backup_configuration}"]
    location_preference         = ["${var.location_preference}"]
    maintenance_window          = ["${var.maintenance_window}"]
  }

  replica_configuration = ["${var.replica_configuration}"]
}

resource "google_sql_database_instance" "replica" {
  depends_on = [
    "google_sql_database_instance.master",
  ]

  name                 = "${var.db_instance_name}-replica"
  count                = "${var.replica_count}"
  region               = "${var.region}"
  database_version     = "${var.database_version}"
  master_instance_name = "${google_sql_database_instance.master.name}"

  settings {
    tier            = "${var.db_machine_type}"
    disk_autoresize = "${var.disk_autoresize}"
  }
}

resource "google_sql_database" "default" {
  name      = "${var.db_name}"
  project   = "${var.project}"
  instance  = "${google_sql_database_instance.master.name}"
  charset   = "${var.db_charset}"
  collation = "${var.db_collation}"
}

resource "random_id" "root-user-password" {
  byte_length = 8
}

resource "google_sql_user" "root" {
  name     = "root"
  project  = "${var.project}"
  instance = "${google_sql_database_instance.master.name}"
  host     = "${var.user_host}"
  password = "${random_id.root-user-password.hex}"
}
