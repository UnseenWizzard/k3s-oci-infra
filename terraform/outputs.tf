output "load_balancer_ip" {
  value = oci_load_balancer_load_balancer.k3s_loadbalancer.ip_address_details
}

output "k3s_public_node_ip" {
  value = oci_core_instance.k3s_server_01.public_ip
}

output "k3s_public_node_id" {
  value = oci_core_instance.k3s_server_01.id
}

output "k3s_public_node_name" {
  value = oci_core_instance.k3s_server_01.display_name
}

output "k3s_cluster_token" {
  value = random_string.cluster_token.result
}
