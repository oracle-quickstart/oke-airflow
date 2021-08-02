FROM odo-docker-signed-local.artifactory.oci.oraclecorp.com/oci-oel7x-jdk11:1.0.268
 
ARG PACKAGES_REPO=https://artifactory.oci.oraclecorp.com/api/pypi/global-release-pypi/simple/
ENV ARTIFACTORY "artifactory.oci.oraclecorp.com"
ARG AIRFLOW_USER_HOME="/opt/airflow"
ENV AIRFLOW_HOME=$AIRFLOW_USER_HOME
 
RUN yum install -y  gcc-c++ gcc openssl-devel libffi-devel \
    tar file make unzip wget curl gzip zip zlib-devel bzip2-devel \
    openssl-devel ncurses-devel mysql readline-devel tk-devel \
    gdbm-devel db4-devel libpcap-devel xz-devel dos2unix openssl cronie vim
 
#Environment Variables
ENV PYTHON_VENV=/opt/pyenv
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.10.0.9-0.0.1.el7_9.x86_64
 
# Creating Directories
 
#COPYING Installers
RUN  wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz
RUN  file Python-3.9.6.tgz && tar -xzf Python-3.9.6.tgz \
     && cd Python-3.9.6 \
     && ./configure  --enable-optimizations \
         && make altinstall && \
         rm -rf ../Python-3.9.6.tgz
 
RUN     ln -sfn /usr/local/bin/python3.7 /usr/bin/python3 && \
        ln -s /usr/local/bin/pip3.7 /usr/bin/pip
 
#Creating a virtual environment and installing wheel which will help to install the application specific dependencies using wheel files.
RUN python3 -m venv $PYTHON_VENV && \
  source $PYTHON_VENV/bin/activate
 
 RUN yum install -y -q wget
 
RUN yum install -y -q freetds-devel krb5-devel cyrus-sasl-devel openssl-devel libffi-devel mariadb-devel sqlite && \
  #chown -R airflow:1000 /opt/pyenv && \
  pip install 'apache-airflow[crypto,kubernetes,mysql]' -i https://artifactory.oci.oraclecorp.com/api/pypi/global-release-pypi/simple/
 
  
# Install OCI python SKD
 
RUN pip install oci -i $PACKAGES_REPO && \
    pip install cx_Oracle -i $PACKAGES_REPO
 
 
# Copy airflow pod template file
COPY pod_template.yaml /opt/airflow/pod_template.yaml
#RUN chown 1000:1000 /opt/airflow/pod_template.yaml
 
 
# Install OCI plugins and copy the script to download OCI DAG templates
RUN mkdir -p /opt/airflow/scripts
COPY install_oci_plugins.sh /opt/airflow/scripts/install_oci_plugins.sh
COPY install_oci_dag_templates.sh /opt/airflow/scripts/install_oci_dag_templates.sh
 
# RUN chown -R 1000:1000 /opt/airflow/scripts && \
RUN chmod +x /opt/airflow/scripts/install_oci_plugins.sh && \
    chmod +x /opt/airflow/scripts/install_oci_dag_templates.sh
 
WORKDIR /opt/airflow
 
 
# Install OCI plugins
RUN whoami
RUN /opt/airflow/scripts/install_oci_plugins.sh
