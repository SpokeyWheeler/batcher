#!/bin/bash

# fail fast
set -eo pipefile

sudo apt-get install -y mysql-server
cp test/my.cnf /etc/my.cnf
cd /tmp
mkdir -p mysql
chown mysql:mysql mysql
chmod 750 mysql
cd mysql
sudo cp test/my.cnf /etc/my.cnf
sudo mysqld --initialize-insecure --user=mysql --datadir=$ pwd )/data

# done
exit 0
