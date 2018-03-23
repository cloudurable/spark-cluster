#!/bin/bash

set -e

KEY_NAME=spark

mkdir -p resources/server/certs
touch ~/.ssh/${KEY_NAME}_rsa.pub
touch ~/.ssh/${KEY_NAME}_rsa
rm ~/.ssh/${KEY_NAME}_rsa.pub
rm ~/.ssh/${KEY_NAME}_rsa

rm -f "$PWD/resources/server/certs/${KEY_NAME}_rsa"
rm -f "$PWD/resources/server/certs/${KEY_NAME}_rsa.pub"


ssh-keygen -t rsa -C "rick.hightower@cloudurable.com" -N "" -C "setup for spark" \
    -f "$PWD/resources/server/certs/${KEY_NAME}_rsa"

chmod 400     "$PWD/resources/server/certs/${KEY_NAME}_rsa"
chmod 400     "$PWD/resources/server/certs/${KEY_NAME}_rsa.pub"

cp "$PWD/resources/server/certs/${KEY_NAME}_rsa" ~/.ssh/${KEY_NAME}_rsa
cp "$PWD/resources/server/certs/${KEY_NAME}_rsa.pub" ~/.ssh/${KEY_NAME}_rsa.pub
