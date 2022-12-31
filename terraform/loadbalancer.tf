resource "oci_load_balancer_load_balancer" "k3s_loadbalancer" {
  #Required
  compartment_id = var.compartment_id
  display_name   = "k3s_load_balancer"
  subnet_ids     = [oci_core_subnet.vcn-public-subnet.id]

  shape = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }

  is_private = false

  freeform_tags = {
    "part_of" = "k3s"
  }
}

resource "oci_load_balancer_backend_set" "k3s_loadbalancer_backendset" {
  name             = "k3s_load_balancer_backendset"
  load_balancer_id = oci_load_balancer_load_balancer.k3s_loadbalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "443"
    protocol            = "TCP"
  }

}

resource "oci_load_balancer_backend" "main_server_backend" {
  #Required
  backendset_name  = oci_load_balancer_backend_set.k3s_loadbalancer_backendset.name
  ip_address       = local.node_config.main_server_ip
  load_balancer_id = oci_load_balancer_load_balancer.k3s_loadbalancer.id
  port             = 443
}

resource "oci_load_balancer_backend" "secondary_server_backend" {
  #Required
  backendset_name  = oci_load_balancer_backend_set.k3s_loadbalancer_backendset.name
  ip_address       = local.node_config.secondary_server_ip
  load_balancer_id = oci_load_balancer_load_balancer.k3s_loadbalancer.id
  port             = 443
}

resource "oci_load_balancer_listener" "k3s_loadbalancer_https_listener" {
  default_backend_set_name = oci_load_balancer_backend_set.k3s_loadbalancer_backendset.name
  load_balancer_id         = oci_load_balancer_load_balancer.k3s_loadbalancer.id
  name                     = "k3s_loadbalancer_https_listener"
  port                     = "443"
  protocol                 = "TCP" # cert-manager and ingresses handle actual HTTPS
}
