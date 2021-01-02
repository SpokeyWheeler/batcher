#!/bin/bash

# fail fast
# set -eo pipefail

# install MariaDB
sudo apt update
sudo apt install -y mariadb-server
sleep 2
sudo systemctl start mariadb
systemctl status mariadb

# done
exit 0
