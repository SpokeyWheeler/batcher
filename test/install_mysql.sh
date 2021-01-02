#!/bin/bash

# fail fast
# set -eo pipefail

sudo apt update
sudo apt-get install -y mysql-server
sudo systemctl start mysql
sleep 10
systemctl status mysql.service

# done
exit 0
