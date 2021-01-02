#!/bin/bash

# fail fast
# set -eo pipefail

# install MariaDB
sudo apt update
sudo apt install -y mariadb-server
#sudo systemctl start mariadb
sleep 2
systemctl status mariadb

# done
exit 0
