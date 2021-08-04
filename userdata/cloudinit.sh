#!/bin/bash
LOG_FILE="/var/log/OCI-airflow-initialize.log"
log() { 
	echo "$(date) [${EXECNAME}]: $*" >> "${LOG_FILE}" 
}
fetch_metadata () {
	region=`curl -s -L http://169.254.169.254/opc/v1/instance/regionInfo/regionIdentifier`
	image_name=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/image_name`
	image_label=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/image_label`
	oke_cluster_id=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/oke_cluster_id`
	nodepool_id=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/nodepool_id`
	repo_name=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/repo_name`
	registry=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/registry`
	registry_user=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/registry_user`
	secret_id=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/secret_id`
	tenancy_ocid=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/tenancy_ocid`
	sql_alchemy_conn=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/sql_alchemy_conn`
	namespace=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/namespace`
	kube_label=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/kube_label`
	mount_target_id=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/mount_target_id`
	nfs_ip=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/nfs_ip`
	admin_db_password=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/admin_db_password | base64 -d`
	admin_db_user=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/admin_db_user`
	db_ip=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/db_ip`
	db_name=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/db_name`
	airflow_db_user=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/airflow_db_user`
	airflow_db_password=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/airflow_db_password | base64 -d`
}

EXECNAME="OCI CLI"
log "->Download"
curl -L -O https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh >> $LOG_FILE
chmod a+x install.sh 
log "->Install"
./install.sh --accept-all-defaults >> $LOG_FILE
echo "export OCI_CLI_AUTH=instance_principal" >> ~/.bash_profile
echo "export OCI_CLI_AUTH=instance_principal" >> ~/.bashrc
echo "export OCI_CLI_AUTH=instance_principal" >> /home/opc/.bash_profile
echo "export OCI_CLI_AUTH=instance_principal" >> /home/opc/.bashrc
EXECNAME="Kubectl & Git"
log "->Install"
yum install -y kubectl git >> $LOG_FILE
mkdir -p /home/opc/.kube
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k='kubectl'" >> ~/.bashrc
echo "source <(kubectl completion bash)" >> /home/opc/.bashrc
echo "alias k='kubectl'" >> /home/opc/.bashrc
source ~/.bashrc
EXECNAME="Docker"
log "->Install"
yum-config-manager --enable ol7_addons >> $LOG_FILE
yum install -y docker-engine docker-cli >> $LOG_FILE
log "->Enable"
systemctl enable docker >> $LOG_FILE
systemctl start docker >> $LOG_FILE
usermod -a -G docker opc 
log "->Build Prep"
mkdir -p /airflow/docker-build
cd /airflow/docker-build
cat > Dockerfile << EOF
FROM python:latest
ARG AIRFLOW_USER_HOME=/opt/airflow
ARG AIRFLOW_USER="airflow"
ARG AIRFLOW_UID="1000"
ARG AIRFLOW_GID="1000"
ENV AIRFLOW_HOME=\$AIRFLOW_USER_HOME

RUN groupadd -g \$AIRFLOW_GID airflow && \\
  useradd -ms /bin/bash -u \$AIRFLOW_UID airflow -g \$AIRFLOW_GID -d \$AIRFLOW_USER_HOME && \\
  chown \$AIRFLOW_USER:\$AIRFLOW_GID \$AIRFLOW_USER_HOME && \\
  buildDeps='freetds-dev libkrb5-dev libsasl2-dev libssl-dev libffi-dev libpq-dev' \\
  apt-get update && \\
  apt-get install -yqq sudo && \\
  apt-get install -yqq wget && \\
  apt-get install -yqq --no-install-recommends \$buildDeps build-essential default-libmysqlclient-dev && \\
  python -m pip install --upgrade pip && \\
  pip install --no-cache-dir 'apache-airflow[crypto,kubernetes,mysql]' && \\
  apt-get purge --auto-remove -yqq \$buildDeps && \\
  apt-get autoremove -yqq --purge && \\
  rm -rf /var/lib/apt/lists/*
# Enable sudo for airflow user without asking for password
RUN usermod -aG sudo \$AIRFLOW_USER && \\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install OCI python SKD
RUN pip install oci && \\
    pip install cx_Oracle

# Copy airflow pod template file
COPY pod_template.yaml \$AIRFLOW_USER_HOME/pod_template.yaml
RUN chown \$AIRFLOW_UID:\$AIRFLOW_GID \$AIRFLOW_USER_HOME/pod_template.yaml

# Install OCI plugins and copy the script to download OCI DAG templates
RUN mkdir -p \$AIRFLOW_USER_HOME/scripts
COPY install_oci_plugins.sh \$AIRFLOW_USER_HOME/scripts/install_oci_plugins.sh
COPY install_oci_dag_templates.sh \$AIRFLOW_USER_HOME/scripts/install_oci_dag_templates.sh
RUN chown -R \$AIRFLOW_UID:\$AIRFLOW_GID \$AIRFLOW_USER_HOME/scripts && \\
    chmod +x \$AIRFLOW_USER_HOME/scripts/install_oci_plugins.sh && \\
    chmod +x \$AIRFLOW_USER_HOME/scripts/install_oci_dag_templates.sh
USER \$AIRFLOW_UID
WORKDIR \$AIRFLOW_USER_HOME

# Install OCI plugins
RUN \$AIRFLOW_USER_HOME/scripts/install_oci_plugins.sh
EOF
cat > install_oci_plugins.sh << EOF
#!/bin/bash
# Install OCI plugins 

hooks_dir="/opt/airflow/plugins/hooks"
operators_dir="/opt/airflow/plugins/operators"
sensors_dir="/opt/airflow/plugins/sensors"

mkdir -p \$hooks_dir
mkdir -p \$operators_dir
mkdir -p \$sensors_dir

plugin_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/master/scripts/plugins
dag_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/master/scripts/dags

# hooks
for file in oci_base.py oci_object_storage.py oci_data_flow.py oci_data_catalog.py oci_adb.py; do
    wget \$plugin_url/hooks/\$file -O \$hooks_dir/\$file
done
# operators
for file in oci_object_storage.py oci_data_flow.py oci_data_catalog.py oci_adb.py oci_copy_object_to_adb.py; do
    wget \$plugin_url/operators/\$file -O \$operators_dir/\$file
done
# sensors
for file in oci_object_storage.py oci_adb.py; do
    wget \$plugin_url/sensors/\$file -O \$sensors_dir/\$file
done
EOF

cat > install_oci_dag_templates.sh << EOF
#!/bin/bash
# Install OCI plugins 

dags_dir="/opt/airflow/dags"

mkdir -p \$dags_dir

dag_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/master/scripts/dags


# Airflow OCI DAGs
for file in oci_simple_example.py oci_advanced_example.py oci_adb_sql_example.py oci_smoketest.py; do
    wget \$dag_url/\$file -O \$dags_dir/\$file
done
for file in schedule_dataflow_app.py schedule_dataflow_with_parameters.py trigger_dataflow_when_file_exists.py; do
    wget \$dag_url/\$file -O \$dags_dir/\$file.template
done
EOF

cat > pod_template.yaml << EOF
---
apiVersion: v1
kind: Pod
metadata:
  name: dummy-name
spec:
  containers:
    - args: []
      command: []
      env:
        - name: AIRFLOW__CORE__EXECUTOR
          value: "KubernetesExecutor"
        - name: AIRFLOW__CORE__SQL_ALCHEMY_CONN
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: sql_alchemy_conn
      envFrom: []
      image: dummy_image
      imagePullPolicy: IfNotPresent
      name: base
      ports: []
      volumeMounts:
        - name: airflow-dags
          mountPath: /opt/airflow/dags
        - name: airflow-logs
          mountPath: /opt/airflow/logs
  volumes:
    - name: airflow-dags
      persistentVolumeClaim:
        claimName: airflow-dags
    - name: airflow-logs
      persistentVolumeClaim:
        claimName: airflow-logs
  #hostNetwork: false
  restartPolicy: Never
  serviceAccountName: airflow
EOF
log "->Build Image"
fetch_metadata
docker build -t ${image_name}:${image_label} . >> $LOG_FILE
log "->Push to Registry"
auth_token=`oci secrets secret-bundle get --secret-id ${secret_id} --stage CURRENT | jq  ."data.\"secret-bundle-content\".content" |  tr -d '"' | base64 -d`
tenancy_name=`oci os ns get | jq ."data" | tr -d '"'`
export tenancy_name=$tenancy_name
docker login ${registry} -u $tenancy_name/${registry_user} -p ${auth_token} >> $LOG_FILE
docker tag "${image_name}:${image_label}" ${registry}/$tenancy_name/${repo_name}/${image_name}:${image_label} >> $LOG_FILE
docker push ${registry}/$tenancy_name/${repo_name}/${image_name}:${image_label} >> $LOG_FILE
cd ..
mkdir airflow-oke
cd airflow-oke
EXECNAME="Kubeconfig"
log "->Generate"
RET_CODE=1
INDEX_NR=1
SLEEP_TIME="10s"
while [ ! -f /root/.kube/config ]
do
	sleep 5
	source ~/.bashrc
	fetch_metadata
	log "-->Attempting to generate kubeconfig"
	oci ce cluster create-kubeconfig --cluster-id ${oke_cluster_id} --file /root/.kube/config  --region ${region} --token-version 2.0.0 >> $LOG_FILE
	log "-->Finished attempt"
done
mkdir -p /home/opc/.kube/
cp /root/.kube/config /home/opc/.kube/config
EXECNAME="OKE Templates"
log "->Build volumes.yaml"
cat > volumes.yaml << EOF
---
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: oci-fss
provisioner: oracle.com/oci-fss
parameters:
     mntTargetId: ${mount_target_id}
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: airflow-dags
spec:
  storageClassName: oci-fss
  accessModes:
    - ReadOnlyMany
  capacity:
    storage: 20Gi
  mountOptions:
   - nosuid
  nfs:
   server: ${nfs_ip}
   path: "/airflow-dags/"
   readOnly: false
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: airflow-dags
spec:
  storageClassName: "oci-fss"
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 20Gi
  volumeName: airflow-dags
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: airflow-logs
spec:
  storageClassName: oci-fss
  accessModes:
    - ReadOnlyMany
  capacity:
    storage: 20Gi
  mountOptions:
   - nosuid
  nfs:
   server: ${nfs_ip}
   path: "/airflow-logs/"
   readOnly: false
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: airflow-logs
spec:
  storageClassName: "oci-fss"
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 20Gi
  volumeName: airflow-logs
---
EOF
log "->Build configmap.yaml"
fetch_metadata
cat > configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: airflow-config
  namespace: ${namespace}
data:
  AIRFLOW_HOME: "/opt/airflow"
  AIRFLOW__CORE__DAGS_FOLDER: "/opt/airflow/dags"
  AIRFLOW__CORE__LOAD_EXAMPLES: "True"
  AIRFLOW__CORE__EXECUTOR: "KubernetesExecutor"
  AIRFLOW__CORE__SQL_ALCHEMY_CONN_SECRET: "sql_alchemy_conn"
  AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE: "/opt/airflow/pod_template.yaml"
  AIRFLOW__KUBERNETES__WORKER_CONTAINER_REPOSITORY: "${registry}/$tenancy_name/${repo_name}/${image_name}"
  AIRFLOW__KUBERNETES__WORKER_CONTAINER_TAG: "${image_label}"
  AIRFLOW__KUBERNETES__WORKER_SERVICE_ACCOUNT_NAME: "airflow"
  AIRFLOW__KUBERNETES__NAMESPACE: "${namespace}"
  #AIRFLOW__LOGGING__BASE_LOG_FOLDER: "/opt/airflow/dags/logs"
  #AIRFLOW__CORE__DAG_PROCESSOR_MANAGER_LOG_LOCATION: "/opt/airflow/dags/logs"
  #AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY: "/opt/airflow/dags/logs"
EOF
log "->Build secrets.yaml"
cat > secrets.yaml << EOF
#  Licensed to the Apache Software Foundation (ASF) under one   *
#  or more contributor license agreements.  See the NOTICE file *
#  distributed with this work for additional information        *
#  regarding copyright ownership.  The ASF licenses this file   *
#  to you under the Apache License, Version 2.0 (the            *
#  "License"); you may not use this file except in compliance   *
#  with the License.  You may obtain a copy of the License at   *
#                                                               *
#    http://www.apache.org/licenses/LICENSE-2.0                 *
#                                                               *
#  Unless required by applicable law or agreed to in writing,   *
#  software distributed under the License is distributed on an  *
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY       *
#  KIND, either express or implied.  See the License for the    *
#  specific language governing permissions and limitations      *
#  under the License.                                           *
apiVersion: v1
kind: Secret
metadata:
  name: airflow-secrets
  namespace: airflow
type: Opaque
data:
  # The sql_alchemy_conn value is a base64 encoded representation of this connection string:
  # mysql+mysql://airflow_username:airflow_password@mysql_db_ip:mysql_db_port/airflow_database
  sql_alchemy_conn: ${sql_alchemy_conn}
EOF
log "->Build airflow.yaml"
cat > airflow.yaml << EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: airflow
  namespace: ${namespace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: airflow
  namespace: ${namespace}
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "watch", "list"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "watch", "list"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["get", "create"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get", "list"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: airflow
  namespace: ${namespace}
subjects:
  - kind: ServiceAccount
    name: airflow
roleRef:
  kind: Role
  name: airflow
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: airflow
  namespace: ${namespace}
  labels:
    app: airflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: airflow
  template:
    metadata:
      labels:
        app: airflow
    spec:
      serviceAccountName: airflow
      initContainers:
      - name: "init"
        image: ${registry}/$tenancy_name/${repo_name}/${image_name}:${image_label}
        imagePullPolicy: Always
        envFrom:
        - configMapRef:
            name: airflow-config
        env:
        - name: AIRFLOW__CORE__SQL_ALCHEMY_CONN
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: sql_alchemy_conn
        command: ["/bin/sh", "-c"]

        args:
          - sudo chown airflow:airflow /opt/airflow/dags;
            sudo chown airflow:airflow /opt/airflow/logs;
            airflow db init;
            airflow users create --username airflow --firstname airflow --lastname airflow --role Admin --password airflow --email admin@airflow.org;
            /opt/airflow/scripts/install_oci_dag_templates.sh;

        volumeMounts:
        - name: airflow-dags
          mountPath: /opt/airflow/dags
        - name: airflow-logs
          mountPath: /opt/airflow/logs  


      containers:

      - name: webserver
        image: ${registry}/$tenancy_name/${repo_name}/${image_name}:${image_label}
        imagePullPolicy: IfNotPresent
        command: ["airflow","webserver"]
        envFrom:
        - configMapRef:
            name: airflow-config
        env:
        - name: AIRFLOW__CORE__SQL_ALCHEMY_CONN
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: sql_alchemy_conn
        volumeMounts:
        - name: airflow-dags
          mountPath: /opt/airflow/dags
        - name: airflow-logs
          mountPath: /opt/airflow/logs  

      - name: scheduler
        image: ${registry}/$tenancy_name/${repo_name}/${image_name}:${image_label}
        imagePullPolicy: IfNotPresent
        command: ["airflow","scheduler"]
        envFrom:
        - configMapRef:
            name: airflow-config
        env:
        - name: AIRFLOW__CORE__SQL_ALCHEMY_CONN
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: sql_alchemy_conn
        volumeMounts:
        - name: airflow-dags
          mountPath: /opt/airflow/dags
        - name: airflow-logs
          mountPath: /opt/airflow/logs  

      volumes:
      - name: airflow-dags
        persistentVolumeClaim:
          claimName: airflow-dags
      - name: airflow-logs
        persistentVolumeClaim:
          claimName: airflow-logs


      imagePullSecrets:
      - name: airflow-ocir-secret
---
apiVersion: v1
kind: Service
metadata:
  name: airflow
  namespace: ${namespace}
spec:
  type: LoadBalancer
  ports:
    - port: 8080
  selector:
    app: airflow
EOF
EXECNAME="OCI MySQL"
log "->Install Client"
yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm >> $LOG_FILE
yum install -y mysql >> $LOG_FILE
log "->Create Airflow DB"
log "-->Building SQL"
echo -e "CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8 COLLATE utf8_unicode_ci;" >> airflow.sql
echo -e "CREATE USER IF NOT EXISTS ${airflow_db_user} IDENTIFIED WITH mysql_native_password BY '${airflow_db_password}';" >> airflow.sql
echo -e -e "GRANT ALL ON ${db_name}.* TO ${airflow_db_user};" >> airflow.sql
log "-->Executing as ${admin_db_user}"
mysql -h ${db_ip} -u ${admin_db_user} -p${admin_db_password} < airflow.sql 2>&1 2>> $LOG_FILE
EXECNAME="Airflow"
log "->OKE Worker check"
SLEEP_TIME="20s"
active_nodes=""
while [ -z "$active_nodes" ]
do
  sleep $SLEEP_TIME
  log "-->Checking if there is a worker node in ACTIVE state" >> $LOG_FILE
  active_nodes=`oci ce node-pool get --node-pool-id ${nodepool_id} --query 'data.nodes[*].{ocid:id, state:"lifecycle-state"}' | jq '.[] | select(.state=="ACTIVE")' | jq ."ocid"`
done
log "-->Nodepool ${nodepool_id}"
log "--->Worker(s) $active_nodes"
log "->Deploy"
log "-->Check for namespace ${namespace}"
done=1
export KUBECONFIG=/root/.kube/config
while [ $done != 0 ]; do 
	kubectl get namespace | grep ${namespace} 
	rt=$?
	if [ $rt != 0 ]; then 
		log "--->${namespace} does not exist, creating."
		kubectl create namespace ${namespace} 2>&1 2>> $LOG_FILE
		sleep 10
	else
		log "--->${namespace} found."
		done=0
	fi
done
log "-->Fetch secret"
kubectl -n ${namespace} get secrets | grep 'airflow-ocir-secret' 2>&1 2>> $LOG_FILE
if [[ $? -ne 0 ]]; then
	log "--->Secret dosn't exist, creating"
        kubectl -n ${namespace} create secret docker-registry airflow-ocir-secret --docker-server=${registry} --docker-username=$tenancy_name/${registry_user} --docker-password=${auth_token} 2>&1 >> $LOG_FILE
fi
log "-->Applying volumes.yaml"
kubectl -n ${namespace} apply -f volumes.yaml 2>&1 2>> $LOG_FILE
log "-->Applying configmap.yaml"
kubectl -n ${namespace} apply -f configmap.yaml 2>&1 2>> $LOG_FILE
log "-->Applying secrets.yaml"
kubectl -n ${namespace} apply -f secrets.yaml 2>&1 2>> $LOG_FILE
log "-->Applying airflow.yaml"
kubectl -n ${namespace} apply -f airflow.yaml 2>&1 2>> $LOG_FILE
log "--->Wait 120s until LB is created and public IP is allocated to airflow service"
sleep 120
log "--->Checking for public IP"
kubectl -n ${namespace} get svc 2>&1 2>> $LOG_FILE
chown -R opc:opc /home/opc
log "DEPLOYMENT DONE"
