#!/bin/bash

# fail fast
set -eo pipefail

sudo cp test/my.cnf /etc/my.cnf
sudo apt-get install -y mysql-server
sudo cp test/my.cnf /etc/my.cnf
cd /tmp
mkdir -p mysql
sudo chown mysql:mysql mysql
sudo chmod 750 mysql
sudo systemctl start mysql
# sudo -s "cd mysql ; mysqld --initialize-insecure --user=mysql --datadir=$ pwd )/data"
cd -

# done
exit 0