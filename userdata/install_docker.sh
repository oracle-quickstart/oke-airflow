#!/bin/bash

# Install docker
sudo yum-config-manager --enable ol7_addons 
sudo yum install -y docker-engine docker-cli


# Enable and start docker daemon
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -a -G docker ${user} 
