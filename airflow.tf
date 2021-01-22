## Create namespace airflow for the airflow microservices
#resource "kubernetes_namespace" "airflow_namespace" {
#  metadata {
#    name = "airflow"
#  }
#  depends_on = [oci_containerengine_node_pool.airflow_webserver_node_pool,oci_containerengine_node_pool.airflow_scheduler_node_pool,oci_containerengine_node_pool.airflow_worker_node_pool,oci_containerengine_node_pool.airflow_mq_node_pool]
#}

# Deploy airflow chart
#resource "helm_release" "airflow" {
#  name      = "airflow"
#  chart     = "helm-chart/airflow"
#  namespace = kubernetes_namespace.airflow_namespace.id
#  wait      = false
#
#  set_string {
#    name  = "global.mock.service"
#    value = var.airflow_mock_mode_all ? "all" : "false"
#  }
#  set {
#    name  = "global.oadbAdminSecret"
#    value = var.db_admin_name
#  }
#  set {
#    name  = "global.oadbConnectionSecret"
#    value = var.db_connection_name
#  }
#  set {
#    name  = "global.oadbWalletSecret"
#    value = var.db_wallet_name
#  }
#  # set {
#  #   name  = "global.oosBucketSecret" # Commented until come with solution to gracefull removal of objects when terraform destroy
#  #   value = var.oos_bucket_name
#  # }
#  set {
#    name  = "tags.atp"
#    value = var.airflow_mock_mode_all ? false : true
#  }
#  set {
#    name  = "tags.streaming"
#    value = var.airflow_mock_mode_all ? false : false
#  }
#
#  depends_on = [helm_release.ingress-nginx] # Ugly workaround because of the oci pvc provisioner not be able to wait for the node be active and retry.
#
#  timeout = 500
#}
