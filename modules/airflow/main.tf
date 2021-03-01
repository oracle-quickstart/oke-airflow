# OCI CLI Installation

data "template_file" "install_oci_cli" {
  template = file("${path.module}/../../userdata/cli_config.sh")
}

resource null_resource "install_oci_cli" {
  depends_on = [var.airflow_depends_on]

  connection {
    host        = var.instance_ip
    private_key = var.ssh_private_key
    timeout     = "200s"
    type        = "ssh"
    user        = "opc"
  }

  provisioner "file" {
    content     = data.template_file.install_oci_cli.rendered
    destination = "~/cli_config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/cli_config.sh",
      "bash $HOME/cli_config.sh",
      "rm -f $HOME/cli_config.sh",
      "rm -f $HOME/install.sh"
    ]
  }
}

# Create airflow DB and grant airflow user full access to it

data "template_file" "create_db" {
  template = file("${path.module}/../../userdata/create_db.sh")
  vars = {
    db_ip = var.db_ip
    db_name = var.db_name
    admin_db_user = var.admin_db_user
    admin_db_password = var.admin_db_password
    airflow_db_user = var.airflow_db_user
    airflow_db_password = var.admin_db_password
  }
}

resource "null_resource" "create_db" {

  connection {
    host        = var.instance_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p $HOME/airflow"
    ]
  }

  provisioner "file" {
    content     = data.template_file.create_db.rendered
    destination = "~/airflow/create_db.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd $HOME/airflow",
      "chmod +x create_db.sh",
      "./create_db.sh"
    ]
  }
}

# Kubectl

data "template_file" "install_kubectl" {
  template = file("${path.module}/../../userdata/install_kubectl.sh")
}

resource "null_resource" "install_kubectl" {
  depends_on = [null_resource.install_oci_cli]

  connection {
    host        = var.instance_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"
  }

  provisioner "file" {
    content     = data.template_file.install_kubectl.rendered
    destination = "~/install_kubectl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_kubectl.sh",
      "bash $HOME/install_kubectl.sh",
      "rm -f $HOME/install_kubectl.sh"
    ]
  }
}

# Kubeconfig

data "template_file" "generate_kubeconfig" {
  template = file("${path.module}/../../userdata/generate_kubeconfig.sh")

  vars = {
    cluster-id = var.cluster_id
    region     = var.region
  }
}

resource "null_resource" "write_kubeconfig_on_bastion" {
  depends_on = [null_resource.install_oci_cli]

  connection {
    host        = var.instance_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"
  }

  provisioner "file" {
    content     = data.template_file.generate_kubeconfig.rendered
    destination = "~/generate_kubeconfig.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/generate_kubeconfig.sh",
      "$HOME/generate_kubeconfig.sh",
      "rm -f $HOME/generate_kubeconfig.sh"
    ]
  }
}

# Checking node lifecycle state

data "template_file" "check_node_lifecycle" {
  template = file("${path.module}/../../userdata/is_worker_active.sh")

  vars = {
    nodepool-id = var.nodepool_id
  }
}

resource "null_resource" "node_lifecycle" {
  depends_on = [null_resource.install_oci_cli]

  connection {
    host        = var.instance_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"
  }

  provisioner "file" {
    content     = data.template_file.check_node_lifecycle.rendered
    destination = "~/is_worker_active.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/is_worker_active.sh",
      "$HOME/is_worker_active.sh",
      "rm -f $HOME/is_worker_active.sh"
    ]
  }
}

# Build airflow docker image with OCI plugins

data "template_file" "install_docker" {
  template = file("${path.module}/../../userdata/install_docker.sh")
  vars = {
    user = "opc" 
  }
}
data "template_file" "Dockerfile" {
  template = file("${path.module}/../../userdata/Dockerfile")
}

data "template_file" "install_oci_plugins" {
  template = file("${path.module}/../../userdata/install_oci_plugins.sh")
}

data "template_file" "install_oci_dag_templates" {
  template = file("${path.module}/../../userdata/install_oci_dag_templates.sh")
}

data "template_file" "pod_template" {
  template = file("${path.module}/../../userdata/templates/pod_template.yaml")
}

resource "null_resource" "build_docker_image" {

  connection {
    host        = var.instance_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"
  }
  
  provisioner "remote-exec" {
    inline = [
      "mkdir -p $HOME/airflow"
        ]
  }

  provisioner "file" {
    content     = data.template_file.install_docker.rendered
    destination = "~/airflow/install_docker.sh"
  }

  provisioner "file" {
    content     = data.template_file.Dockerfile.rendered
    destination = "~/airflow/Dockerfile"
  }
  
  provisioner "file" {
    content     = data.template_file.install_oci_plugins.rendered
    destination = "~/airflow/install_oci_plugins.sh"
  }

  provisioner "file" {
    content     = data.template_file.install_oci_dag_templates.rendered
    destination = "~/airflow/install_oci_dag_templates.sh"
  }

  provisioner "file" {
    content     = data.template_file.pod_template.rendered
    destination = "~/airflow/pod_template.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd $HOME/airflow",
      "chmod +x install_docker.sh",
      "./install_docker.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cd airflow; docker build -t ${var.image_name}:${var.image_label} ."
    ]
  }
}

# Push airflow image to OCI registry

data "template_file" "push_to_registry" {
  template = file("${path.module}/../../userdata/push_to_registry.sh")
  vars = {
    secret_id = var.secret_id,
    registry = var.registry
    repo_name = var.repo_name
    registry_user = var.registry_user
    tenancy_name = data.oci_identity_tenancy.my_tenancy.name
    region = var.region
    image_name = var.image_name
    image_label = var.image_label
  }
}

resource "null_resource" "push_to_registry" {
  depends_on = [null_resource.build_docker_image]

  connection {
    host        = var.instance_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"
  }

  provisioner "file" {
    content     = data.template_file.push_to_registry.rendered
    destination = "~/airflow/push_to_registry.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd $HOME/airflow",
      "chmod +x push_to_registry.sh",
      "./push_to_registry.sh"
    ]
  }
}


# Deploy airflow containers on OKE

data "template_file" "deploy_airflow" {
  template = file("${path.module}/../../userdata/deploy_airflow.sh")
  vars = {
    secret_id = var.secret_id
    registry = var. registry
    repo_name = var.repo_name
    registry_user = var.registry_user
    tenancy_name = data.oci_identity_tenancy.my_tenancy.name
    region = var.region
    image_name = var.image_name
    image_label = var.image_label
    namespace = var.namespace
    mount_target_id = var.mount_target_id
    nfs_ip = var.nfs_ip
  }
}

data "template_file" "volumes_template" {
  template = file("${path.module}/../../userdata/templates/volumes.yaml.template")
  vars = {
    MNT_TARGET_ID = var.mount_target_id
    NFS_IP = var.nfs_ip
  }
}

data "template_file" "configmap_template" {
  template = file("${path.module}/../../userdata/templates/configmap.yaml.template")
  vars = {
    namespace = var.namespace
    registry = var.registry
    tenancy_name = data.oci_identity_tenancy.my_tenancy.name
    repo_name = var.repo_name
    image_name = var.image_name
    image_label = var.image_label
  }
}

data "template_file" "secrets_template" {
  template = file("${path.module}/../../userdata/templates/secrets.yaml.template")
  vars = {
    sql_alchemy_conn = local.sql_alchemy_conn
  }
}


data "template_file" "airflow_template" {
  template = file("${path.module}/../../userdata/templates/airflow.yaml.template")
  vars = {
    namespace = var.namespace
    registry = var.registry
    tenancy_name = data.oci_identity_tenancy.my_tenancy.name
    repo_name = var.repo_name
    image_name = var.image_name
    image_label = var.image_label
  }
}


resource "null_resource" "deploy_airflow" {
  depends_on = [null_resource.push_to_registry, null_resource.node_lifecycle]

  connection {
    host        = var.instance_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p $HOME/airflow/build"
    ]
  }

  provisioner "file" {
    content     = data.template_file.volumes_template.rendered
    destination = "~/airflow/build/volumes.yaml"
  }

  provisioner "file" {
    content     = data.template_file.configmap_template.rendered
    destination = "~/airflow/build/configmap.yaml"
  }  

  provisioner "file" {
    content     = data.template_file.airflow_template.rendered
    destination = "~/airflow/build/airflow.yaml"
  }  

  provisioner "file" {
    content     = data.template_file.secrets_template.rendered
    destination = "~/airflow/build/secrets.yaml"
  }  

  
  provisioner "file" {
    content     = data.template_file.deploy_airflow.rendered
    destination = "~/airflow/deploy_airflow.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "cd $HOME/airflow",
      "chmod +x deploy_airflow.sh",
      "./deploy_airflow.sh"
    ]
  }
}