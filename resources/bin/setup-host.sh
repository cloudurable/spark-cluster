#!/bin/bash
set -e

echo "HOSTNAME=$1" >> /etc/sysconfig/network
hostname $1
echo "HOSTNAME=$1" >> /etc/environment
/etc/init.d/network restart
