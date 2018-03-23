#!/bin/bash
set -e


ssh-keyscan -t rsa node0 node1 node2 bastion > /home/ansible/.ssh/known_hosts
ssh-keyscan -t rsa 192.168.50.4 192.168.50.5 192.168.50.6 192.168.50.20 >> /home/ansible/.ssh/known_hosts
