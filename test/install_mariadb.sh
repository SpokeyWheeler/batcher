#!/bin/bash

# fail fast
# set -eo pipefail

# install MariaDB
# sudo cp test/my.cnf /etc/mysql/my.cnf
sudo apt install wget
# cd /tmp
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
echo "b7519209546e1656e5514c04b4dcffdd9b4123201bcd1875a361ad79eb943bbe mariadb_repo_setup" | sha256sum -c -
chmod +x mariadb_repo_setup
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-10.5"
sudo apt update
sudo apt install -y mariadb-server
# cd -
# sudo cp test/my.cnf /etc/mysql/my.cnf
# cd /tmp
# mkdir -p mariadb
# sudo chown mysql:mysql mariadb
# sudo chmod 750 mariadb
sudo systemctl start mariadb
# sudo -s "cd mariadb ; mariadbd --initialize-insecure --user=mysql --datadir=$ pwd )/data"
# cd -

# done
exit 0
