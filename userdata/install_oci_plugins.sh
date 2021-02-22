#!/bin/bash
# Install OCI plugins 

mkdir -p $HOME/airflow/plugins/hooks
mkdir -p $HOME/airflow/plugins/operators
mkdir -p $HOME/airflow/plugins/sensors
mkdir -p $HOME/airflow/dags

#plugin_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/master/scripts/plugins
#dags_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/master/scripts/dags
plugin_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/devel/scripts/plugins
dag_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/devel/scripts/dags

# hooks
for file in oci_base.py oci_object_storage.py oci_data_flow.py oci_data_catalog.py oci_adb.py; do
    wget $plugin_url/hooks/$file -O $HOME/airflow/plugins/hooks/$file
done
# operators
for file in oci_object_storage.py oci_data_flow.py oci_data_catalog.py oci_adb.py oci_copy_object_to_adb.py; do
    wget $plugin_url/operators/$file -O $HOME/airflow/plugins/operators/$file
done
# sensors
for file in oci_object_storage.py oci_adb.py; do
    wget $plugin_url/sensors/$file -O $HOME/airflow/plugins/sensors/$file
done

# Airflow OCI customization
for file in oci_simple_example.py oci_advanced_example.py oci_adb_sql_example.py oci_smoketest.py; do
    wget $dag_url/$file -O $HOME/airflow/dags/$file
done
for file in schedule_dataflow_app.py schedule_dataflow_with_parameters.py trigger_dataflow_when_file_exists.py; do
    wget $dag_url/$file -O $HOME/airflow/dags/$file.template
done
