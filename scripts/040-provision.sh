#!/bin/bash
set -e

yum install -y epel-release
yum update -y

yum install -y wget
yum install -y java-1.8.0-openjdk
yum install -y ntp
yum install -y net-tools


## Needed for Cassandra but not for just Spark
# yum install -y jna
# yum install -y jemalloc
