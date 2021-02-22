#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# trying until:
# - instance-principal rights are active
# - kubeconfig generation is successful
RET_CODE=1
INDEX_NR=1
SLEEP_TIME="20s"
    while [ $RET_CODE -ne 0 ]
    do
        echo "Started sleep. INDEX_NR is: $INDEX_NR. SLEEP_TIME is $SLEEP_TIME"
        sleep $SLEEP_TIME
        echo "Finished sleep"

        echo "Started generating config: ${cluster-id} ${region}"
        oci ce cluster create-kubeconfig --cluster-id ${cluster-id} --file $HOME/.kube/config  --region ${region} --token-version 2.0.0
        RET_CODE=$?
        echo "Finished generating config. RET_CODE is : $RET_CODE"

        ((INDEX_NR+=1))
    done
