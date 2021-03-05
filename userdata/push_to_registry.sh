#!/bin/bash

# Get authentication token stored in OCI vault 
auth_token=`oci secrets secret-bundle get --secret-id ${secret_id} --stage CURRENT | jq  ."data.\"secret-bundle-content\".content" |  tr -d '"' | base64 --decode`

# Get tenancy name
#tenancy_name=`oci iam tenancy get --tenancy-id $tenancy_id | jq ."data.name" | tr -d '"'`

# Login OCI registry
docker login ${registry} -u ${tenancy_name}/${registry_user} -p $auth_token

# Tag container image
docker tag "${image_name}:${image_label}" ${registry}/${tenancy_name}/${repo_name}/${image_name}:${image_label}

# Push container image to OCI registry
docker push ${registry}/${tenancy_name}/${repo_name}/${image_name}:${image_label}

