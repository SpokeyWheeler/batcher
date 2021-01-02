#!/bin/bash

# fail fast
# set -eo pipefail

# install MariaDB
sudo apt update
sudo apt install -y mariadb-server
mysql_install_db --auth-root-authentication-method=normal --verbose --force
systemctl status mariadb

# done
exit 0
