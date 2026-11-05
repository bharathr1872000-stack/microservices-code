#!/bin/bash
apt-get update -y
apt-get install -y ca-certificates curl unzip git
curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu
apt-get install -y docker-compose-plugin
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli.zip
unzip -q /tmp/awscli.zip -d /tmp && /tmp/aws/install
systemctl enable --now docker
mkdir -p /opt/app && chown ubuntu:ubuntu /opt/app
