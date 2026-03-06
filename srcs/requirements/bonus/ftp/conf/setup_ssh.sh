#!/bin/bash
apt-get update && apt-get install -y openssh-server
mkdir -p /var/run/sshd
useradd -m wpuser && echo "wpuser:owmarqui42" | chpasswd
chown -R wpuser:wpuser /var/www/html
service ssh start