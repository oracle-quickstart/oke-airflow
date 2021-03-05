#!/bin/bash
# Install OCI plugins 

hooks_dir="$HOME/plugins/hooks"
operators_dir="$HOME/plugins/operators"
sensors_dir="$HOME/plugins/sensors"

mkdir -p $hooks_dir
mkdir -p $operators_dir
mkdir -p $sensors_dir

plugin_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/master/scripts/plugins
dag_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/master/scripts/dags

# hooks
for file in oci_base.py oci_object_storage.py oci_data_flow.py oci_data_catalog.py oci_adb.py; do
    wget $plugin_url/hooks/$file -O $hooks_dir/$file
done
# operators
for file in oci_object_storage.py oci_data_flow.py oci_data_catalog.py oci_adb.py oci_copy_object_to_adb.py; do
    wget $plugin_url/operators/$file -O $operators_dir/$file
done
# sensors
for file in oci_object_storage.py oci_adb.py; do
    wget $plugin_url/sensors/$file -O $sensors_dir/$file
done
