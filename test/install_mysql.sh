#!/bin/bash

# fail fast
set -eo pipefile

sudo cp test/my.cnf /etc/my.cnf
sudo apt-get install -y mysql-server
sudo cp test/my.cnf /etc/my.cnf
cd /tmp
mkdir -p mysql
chown mysql:mysql mysql
chmod 750 mysql
cd mysql
sudo mysqld --initialize-insecure --user=mysql --datadir=$ pwd )/data

# done
exit 0
