#!/bin/bash
# Install OCI plugins 

dags_dir="$HOME/dags"

mkdir -p $dags_dir

# Check if DAGs are already copied to DAGs folder
if [ -f $dags_dir/.dags ]
then
	exit 0
fi


dag_url=https://raw.githubusercontent.com/oracle-quickstart/oci-airflow/master/scripts/dags


# Airflow OCI DAGs
for file in oci_simple_example.py oci_advanced_example.py oci_adb_sql_example.py oci_smoketest.py; do
    wget $dag_url/$file -O $dags_dir/$file
done
for file in schedule_dataflow_app.py schedule_dataflow_with_parameters.py trigger_dataflow_when_file_exists.py; do
    wget $dag_url/$file -O $dags_dir/$file.template
done

touch $dags_dir/.dags
