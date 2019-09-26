# Core variables
variable "credentials" {
  type = "string"
}

variable "ssh_user" {
  type = "string"
  description = "Name of the SSH user to use"
  default = "app"
}

variable "ssh_public_key" {
  type = "string"
  description = "Location of the public RSA key used for SSH-ing onto the main VM"
}

variable "ssh_private_key" {
  type = "string"
  description = "Location of the private RSA key used for SSH-ing onto the main VM"
}

variable "project" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "zone" {
  type = "string"
}

variable "core_machine_type" {
  type = "string"
}

variable "instance_name" {
  type = "string"
}

variable "core_image" {
  type = "string"
}

# SQL variables

variable db_instance_name {
  description = "Name for the database instance. Must be unique and cannot be reused for up to one week."
}

variable database_version {
  description = "The version of of the database. For example, `MYSQL_5_6` or `POSTGRES_9_6`."
  default     = "MYSQL_5_6"
}

variable tier {
  description = "The machine tier (First Generation) or type (Second Generation). See this page for supported tiers and pricing: https://cloud.google.com/sql/pricing"
  default     = "db-f1-micro"
}

variable db_name {
  description = "Name of the default database to create"
  default     = "default"
}

variable db_charset {
  description = "The charset for the default database"
  default     = ""
}

variable db_collation {
  description = "The collation for the default database. Example for MySQL databases: 'utf8', and Postgres: 'en_US.UTF8'"
  default     = ""
}

variable user_name {
  description = "The name of the default user"
  default     = "root"
}

variable user_host {
  description = "The host for the default user"
  default     = "%"
}

variable user_password {
  description = "The password for the default user. If not set, a random one will be generated and available in the generated_user_password output variable."
  default     = ""
}

variable activation_policy {
  description = "This specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  default     = "ALWAYS"
}

variable authorized_gae_applications {
  description = "A list of Google App Engine (GAE) project names that are allowed to access this instance."
  type        = "list"
  default     = []
}

variable disk_autoresize {
  description = "Second Generation only. Configuration to increase storage size automatically."
  default     = true
}

variable disk_size {
  description = "Second generation only. The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased."
  default     = 10
}

variable db_disk_type {
  description = "Second generation only. The type of data disk: `PD_SSD` or `PD_HDD`."
  default     = "PD_SSD"
}

variable pricing_plan {
  description = "First generation only. Pricing plan for this instance, can be one of `PER_USE` or `PACKAGE`."
  default     = "PER_USE"
}

variable replication_type {
  description = "Replication type for this instance, can be one of `ASYNCHRONOUS` or `SYNCHRONOUS`."
  default     = "SYNCHRONOUS"
}

variable backup_configuration {
  description = "The backup_configuration settings subblock for the database setings"
  type        = "map"
  default     = {
    enabled = true
    binary_log_enabled = true
    start_time = "03:00"
  }
}

variable ip_configuration {
  description = "The ip_configuration settings subblock"
  type        = "list"
  default     = [{}]
}

variable location_preference {
  description = "The location_preference settings subblock"
  type        = "list"
  default     = []
}

variable replica_count {
  description = "Number of database replicas"
  default = "1"
}

variable maintenance_window {
  description = "The maintenance_window settings subblock"
  type        = "list"
  default     = []
}

variable replica_configuration {
  description = "The optional replica_configuration block for the database instance"
  type        = "list"
  default     = []
}

# Cryptonode variables

variable "network_name" {
  type    = "string"
  default = "default"
}

variable "subnetwork_name" {
  type    = "string"
  default = "default"
}

variable "cryptonode_machine_type" {
  type = "string"
}

variable "bitcoind_image" {
  type = "string"
}

variable "bitcoind_rpcport" {
  type = "string"
}

variable "bitcoind_port" {
  type = "string"
}

variable "parity_image" {
  type = "string"
}

variable "parity_rpcport" {
  type = "string"
}

variable "parity_port" {
  type = "string"
}
