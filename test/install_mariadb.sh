#!/bin/bash

# fail fast
set -eo pipefail

# install MariaDB
sudo cp test/my.cnf /etc/my.cnf
sudo apt install -y mariadb-server
sudo cp test/my.cnf /etc/my.cnf
cd /tmp
mkdir -p mariadb
sudo chown mysql:mysql mariadb
sudo chmod 750 mariadb
sudo systemctl start mariadb
# sudo -s "cd mariadb ; mariadbd --initialize-insecure --user=mysql --datadir=$ pwd )/data"
cd -

# done
exit 0