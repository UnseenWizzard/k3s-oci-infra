terraform {
  required_version = "~> 1.3.6" 
  
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "~> 4.102.0"
    }
  }

  backend "http" {} # use OCI Object storage with pre-authorized url, define as config file, pass as -backend-config={file}
}

provider "oci" {
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  private_key_path = var.api_private_key_path
  fingerprint      = var.api_fingerprint
  region           = var.region
}

module "vcn" {
  source         = "oracle-terraform-modules/vcn/oci"
  version        = "3.5.3"
  compartment_id = var.compartment_id
  region         = var.region

  vcn_name  = "k3s_vcn"
  vcn_cidrs = ["10.0.0.0/16"]

  create_internet_gateway = true

  freeform_tags = {
    "part_of" = "k3s"
  }
}
