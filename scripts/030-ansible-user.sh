#!/bin/bash
set -e

# Enable sudo w/o password
sed -i -e '/Defaults    requiretty/{ s/.*/# Defaults    requiretty/ }' /etc/sudoers
sed -i -e '/%wheel\tALL=(ALL)\tALL/{ s/.*/%wheel\tALL=(ALL)\tNOPASSWD:\tALL/ }' /etc/sudoers

# Setup ansible user
adduser ansible
usermod -aG wheel ansible
mkdir  -p  /home/ansible/.ssh/
touch /home/ansible/.ssh/authorized_keys
cat /vagrant/resources/server/certs/*.pub >> /home/ansible/.ssh/authorized_keys
cp /vagrant/resources/server/certs/*  /home/ansible/.ssh
cp /vagrant/ssh/ssh.config /home/ansible/.ssh/config
# ssh-keyscan node0 node1 node2  bastion >> /home/ansible/.ssh/known_hosts
chown -R ansible /home/ansible/.ssh/
