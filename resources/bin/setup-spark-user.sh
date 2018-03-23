#!/bin/bash

exec > >(tee /var/log/setup-spark-user.log|logger -t spark-setup -s 2>/dev/console) 2>&1

set -x

echo "adding spark user"
adduser spark
usermod -aG wheel spark

echo "setting up keys for spark user"
mkdir  -p  /home/spark/.ssh/
touch /home/spark/.ssh/authorized_keys
cat /vagrant/resources/server/certs/*.pub >> /home/spark/.ssh/authorized_keys
cp /vagrant/resources/server/certs/*  /home/spark/.ssh
cp /vagrant/ssh/ssh.config /home/spark/.ssh/config

echo "key-scan for spark user"
ssh-keyscan -t rsa node0 node1 node2 bastion > /home/spark/.ssh/known_hosts
ssh-keyscan -t rsa 192.168.50.4 192.168.50.5 192.168.50.6 192.168.50.20 >> /home/spark/.ssh/known_hosts

echo "chown directories for spark user"
chown -R spark /home/spark/.ssh/
chown -R spark /opt/spark/
