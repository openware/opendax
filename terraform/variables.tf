variable "credentials" {
  type = string
}

variable "ssh_user" {
  type        = string
  description = "Name of the SSH user to use"
  default     = "app"
}

variable "ssh_public_key" {
  type        = string
  description = "Location of the public RSA key used for SSH-ing onto the main VM"
}

variable "ssh_private_key" {
  type        = string
  description = "Location of the private RSA key used for SSH-ing onto the main VM"
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "image" {
  type = string
}

