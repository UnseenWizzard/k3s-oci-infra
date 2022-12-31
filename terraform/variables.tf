variable "api_fingerprint" {
  description = "fingerprint of oci api private key"
  type        = string
}

variable "api_private_key_path" {
  description = "path to oci api private key used"
  type        = string
}

variable "tenancy_id" {
  description = "tenancy id where to create the sources"
  type        = string
}

variable "compartment_id" {
  description = "id of compartment to create the resource in"
  type        = string
}

variable "user_id" {
  description = "id of user that terraform will use to create the resources"
  type        = string
}

variable "region" {
  description = "region to create the resources in"
  type        = string
}

variable "ssh_key_path" {
  description = "path to public ssh key to put on instances"
  type        = string
}

variable "public_url" {
  description = "public url to also configure main server for"
  type = string
}

locals {
  node_config = {
    main_server_ip      = "10.0.0.42"
    secondary_server_ip = "10.0.0.43"
    agent_01_ip         = "10.0.0.100"

    k3os_image          = "https://github.com/rancher/k3os/releases/download/v0.21.5-k3s2r1/k3os-arm64.iso"
  }
}
