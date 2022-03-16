FROM python:latest

ARG AIRFLOW_USER_HOME=/opt/airflow
ARG AIRFLOW_USER="airflow"
ARG AIRFLOW_UID="1000"
ARG AIRFLOW_GID="1000"
ENV AIRFLOW_HOME=$AIRFLOW_USER_HOME

RUN groupadd -g $AIRFLOW_GID airflow && \
  useradd -ms /bin/bash -u $AIRFLOW_UID airflow -g $AIRFLOW_GID -d $AIRFLOW_USER_HOME && \
  chown $AIRFLOW_USER:$AIRFLOW_GID $AIRFLOW_USER_HOME && \
  buildDeps='freetds-dev libkrb5-dev libsasl2-dev libssl-dev libffi-dev libpq-dev' \
  apt-get update && \
  apt-get install -yqq sudo && \
  apt-get install -yqq wget && \
  apt-get install -yqq --no-install-recommends $buildDeps build-essential default-libmysqlclient-dev && \
  pip3 install --no-cache-dir 'apache-airflow[crypto,kubernetes,mysql]' && \
  pip3 install --no-cache-dir 'pandas' && \
  apt-get purge --auto-remove -yqq $buildDeps && \
  apt-get autoremove -yqq --purge && \
  rm -rf /var/lib/apt/lists/*

# Enable sudo for airflow user without asking for password
RUN usermod -aG sudo $AIRFLOW_USER && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


# Install OCI python SKD
RUN pip3 install oci && \
    pip3 install cx_Oracle

# Copy airflow pod template file
COPY pod_template.yaml $AIRFLOW_USER_HOME/pod_template.yaml
RUN chown $AIRFLOW_UID:$AIRFLOW_GID $AIRFLOW_USER_HOME/pod_template.yaml

# Install OCI plugins and copy the script to download OCI DAG templates
RUN mkdir -p $AIRFLOW_USER_HOME/scripts
COPY install_oci_plugins.sh $AIRFLOW_USER_HOME/scripts/install_oci_plugins.sh
COPY install_oci_dag_templates.sh $AIRFLOW_USER_HOME/scripts/install_oci_dag_templates.sh
RUN chown -R $AIRFLOW_UID:$AIRFLOW_GID $AIRFLOW_USER_HOME/scripts && \
    chmod +x $AIRFLOW_USER_HOME/scripts/install_oci_plugins.sh && \
    chmod +x $AIRFLOW_USER_HOME/scripts/install_oci_dag_templates.sh

USER $AIRFLOW_UID

WORKDIR $AIRFLOW_USER_HOME

# Install OCI plugins
RUN $AIRFLOW_USER_HOME/scripts/install_oci_plugins.sh

