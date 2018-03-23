#!/bin/bash
set -e


# Set up host file for other nodes

echo Building host file
/vagrant/scripts/020-hosts.sh

echo Creating ansible user
/vagrant/scripts/030-ansible-user.sh

cp /vagrant/ansible.cfg .
cp /vagrant/inventory.ini .
mkdir ssh
sudo cp /vagrant/ssh/ssh.config ssh/ssh.config
sudo chown ansible ssh/ssh.config

# Install packages
yum install -y epel-release
yum update -y
yum install -y  ansible
