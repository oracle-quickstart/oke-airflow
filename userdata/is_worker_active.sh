#!/bin/bash
SLEEP_TIME="20s"
active_nodes=""
while [ -z "$active_nodes" ]
do
  sleep $SLEEP_TIME
  echo "Checking if there is a worker node in ACTIVE state" 
  active_nodes=`oci ce node-pool get --node-pool-id ${nodepool-id} --query 'data.nodes[*].{ocid:id, state:"lifecycle-state"}' | jq '.[] | select(.state=="ACTIVE")' | jq ."ocid"`
done
echo $active_nodes
