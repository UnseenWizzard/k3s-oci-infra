# TODO: simplify these 
resource "oci_core_instance" "k3s_server_01" {

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 4
  }

  source_details {
    source_id   = var.base_ubuntu_image_ocid
    source_type = "image"
  }

  display_name = "k3s-server-01"
  create_vnic_details {
    assign_public_ip = true
    private_ip       = local.node_config.main_server_ip
    subnet_id        = oci_core_subnet.vcn-public-subnet.id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_key_path)
    user_data = base64encode(
      templatefile("${path.module}/templates/main_server_user_data.sh",
        {
          main_server_ip = local.node_config.main_server_ip,
          host_name      = "k3s-server-01",
          public_url     = var.public_url,
          ssh_public_key = file(var.ssh_key_path),
          token          = random_string.cluster_token.result,
          k3os_image     = local.node_config.k3os_image
      })
    )
  }

  freeform_tags = {
    "part_of" = "k3s"
  }
}

resource "oci_core_instance" "k3s_server_02" {

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 4
  }

  source_details {
    source_id   = var.base_ubuntu_image_ocid
    source_type = "image"
  }

  display_name = "k3s-server-02"
  create_vnic_details {
    assign_public_ip = true
    private_ip       = local.node_config.secondary_server_ip
    subnet_id        = oci_core_subnet.vcn-public-subnet.id
  }
  metadata = {
    ssh_authorized_keys = file(var.ssh_key_path)
    user_data = base64encode(
      templatefile("${path.module}/templates/server_user_data.sh",
        {
          main_server_ip = local.node_config.main_server_ip,
          host_name      = "k3s-server-02",
          ssh_public_key = file(var.ssh_key_path),
          token          = random_string.cluster_token.result,
          k3os_image     = local.node_config.k3os_image
      })
    )
  }

  freeform_tags = {
    "part_of" = "k3s"
  }

  depends_on = [
    oci_core_instance.k3s_server_01
  ]
}

resource "oci_core_instance" "k3s_agent_01" {

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  source_details {
    source_id   = var.base_ubuntu_image_ocid
    source_type = "image"
  }

  display_name = "k3s-agent-01"
  create_vnic_details {
    assign_public_ip = true
    private_ip       = local.node_config.agent_01_ip
    subnet_id        = oci_core_subnet.vcn-public-subnet.id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_key_path)
    user_data = base64encode(
      templatefile("${path.module}/templates/agent_user_data.sh",
        {
          main_server_ip = local.node_config.main_server_ip,
          host_name      = "k3s-agent-01",
          ssh_public_key = file(var.ssh_key_path),
          token          = random_string.cluster_token.result,
          k3os_image     = local.node_config.k3os_image
      })
    )
  }


  freeform_tags = {
    "part_of" = "k3s"
  }

  depends_on = [
    oci_core_instance.k3s_server_02
  ]
}
