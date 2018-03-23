#!/bin/bash
set -e



cd /vagrant/


echo Building host file
scripts/020-hosts.sh
echo Creating ansible user
scripts/030-ansible-user.sh
echo RUNNING PROVISION / install yum
#scripts/040-provision.sh
