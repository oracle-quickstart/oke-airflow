#?/bin/bash
set -x

#build_dir="$HOME/airflow/build"
#mkdir -p $build_dir
#cd $build_dir

# Create airflow namespace (if it does not exist)
kubectl get namespaces | grep ${namespace}
if [[ $? -ne 0 ]]; then
kubectl create namespace ${namespace}
fi

# Get authentication token stored in OCI vault 
auth_token=`oci secrets secret-bundle get --secret-id ${secret_id} --stage CURRENT | jq  ."data.\"secret-bundle-content\".content" |  tr -d '"' | base64 --decode`

# Create ocir registry secret (if it does not exist already)
kubectl -n ${namespace} get secrets | grep 'airflow-ocir-secret' 
if [[ $? -ne 0 ]]; then
	kubectl -n ${namespace} create secret docker-registry airflow-ocir-secret --docker-server=${registry} --docker-username=${tenancy_name}/${registry_user} --docker-password=$auth_token
fi

echo "NFS IP:" ${nfs_ip}
echo "Mount target ID:" ${mount_target_id}

cd $HOME/airflow/build

# Create NFS persistent volumes using FSS mount target
kubectl -n ${namespace} apply -f volumes.yaml

# Create airflow config map with container environment variables
kubectl -n ${namespace} apply -f configmap.yaml

# Create airflow secret (encoded DB connection string)
kubectl -n ${namespace} apply -f secrets.yaml

# Deploy airflow containers
kubectl -n ${namespace} apply -f airflow.yaml

# Wait until LB is created and public IP is allocated to airflow service
sleep 120

# Get service public IP address
kubectl -n ${namespace} get svc
