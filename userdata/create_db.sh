
#/bin/bash

# Install MySQL client
sudo yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum install -y mysql

# Connect to MySQL instance and create airflow database and user
mysql  -h ${db_ip} -u ${admin_db_user} -p${admin_db_password} -e "CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8 COLLATE utf8_unicode_ci;;"
mysql  -h ${db_ip} -u ${admin_db_user} -p${admin_db_password} -e "CREATE USER IF NOT EXISTS ${airflow_db_user} IDENTIFIED WITH mysql_native_password BY '${airflow_db_password}'"
mysql  -h ${db_ip} -u ${admin_db_user} -p${admin_db_password} -e "GRANT ALL ON ${db_name}.* TO ${airflow_db_user}"
