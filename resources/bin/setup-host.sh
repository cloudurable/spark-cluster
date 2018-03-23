#!/bin/bash
set -e

echo "HOSTNAME=$1" >> /etc/sysconfig/network
hostname $1
echo "HOSTNAME=$1" >> /etc/environment
echo $1 > /etc/hostname
hostnamectl set-hostname $1
/etc/init.d/network restart
