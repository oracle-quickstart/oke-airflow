#!/bin/bash

# Install docker
sudo yum install -y docker

# Enable and start docker daemon
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -a -G docker ${user} 

