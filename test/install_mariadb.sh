#!/bin/bash

# fail fast
set -eo pipefail

# install MariaDB
cp test/my.cnf /etc/my.cnf
sudo apt install -y mariadb-server
cd /tmp
mkdir -p mariadb
chown mysql:mysql mariadb
chmod 750 mariadb
cd mariadb
sudo cp test/my.cnf /etc/my.cnf
sudo mariadbd --initialize-insecure --user=mysql --datadir=$ pwd )/data

# done
exit 0
