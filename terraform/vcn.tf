# TODO: drop unnecessary private subnet (free tier needs public IPs for compute to be able to reach the internet - no NAT gateway)
resource "oci_core_security_list" "private-security-list" {

  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  display_name = "k3s-private-subnet-security-list"

  freeform_tags = {
    "part_of" = "k3s"
  }

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }


  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # k3s (https://docs.k3s.io/installation/requirements#networking)
  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }

}

resource "oci_core_security_list" "public-security-list" {

  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  display_name = "k3s-public-subnet-security-list"

  freeform_tags = {
    "part_of" = "k3s"
  }

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }


  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }

    ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # k3s server-server (https://docs.k3s.io/installation/requirements#networking)
  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 2379
      max = 2380
    }
  }

  # k3s (https://docs.k3s.io/installation/requirements#networking)
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 6443
      max = 6443
    }
  }


  # k3s kubelet metrics (https://docs.k3s.io/installation/requirements#networking)
  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 10250
      max = 10250
    }
  }

  # k3s kubelet metrics (https://docs.k3s.io/installation/requirements#networking)
  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 10250
      max = 10250
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }

}

resource "oci_core_subnet" "vcn-private-subnet"{
  compartment_id = var.compartment_id
  vcn_id = module.vcn.vcn_id
  cidr_block = "10.0.1.0/24"

  freeform_tags = {
    "part_of" = "k3s"
  }
 
  route_table_id = module.vcn.nat_route_id
  security_list_ids = [oci_core_security_list.private-security-list.id]
  display_name = "k3s_private-subnet"
}

resource "oci_core_subnet" "vcn-public-subnet"{

  compartment_id = var.compartment_id
  vcn_id = module.vcn.vcn_id
  cidr_block = "10.0.0.0/24"

  freeform_tags = {
    "part_of" = "k3s"
  }

  route_table_id = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name = "k3s_public-subnet"
}