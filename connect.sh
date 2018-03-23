#!/bin/bash
ssh  -o StrictHostKeyChecking=no \
    -i resources/server/certs/spark_rsa  \
    ansible@$1
