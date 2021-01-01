#!/bin/bash

# fail fast
# set -eo pipefail

# wget -c https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb
# sudo dpkg -i mysql-apt-config_0.8.11-1_all.deb
sudo apt update
sudo apt-get install -y mysql-server
# sudo cp test/my.cnf /etc/my.cnf
# cd /tmp
# mkdir -p mysql
# sudo chown mysql:mysql mysql
# sudo chmod 750 mysql
sudo systemctl start mysql
systemctl status mysql.service
# sudo -s "cd mysql ; mysqld --initialize-insecure --user=mysql --datadir=$ pwd )/data"
# cd -

# done
exit 0
