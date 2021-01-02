#!/bin/bash

# fail fast
# set -eo pipefail

# install MariaDB
# sudo apt update
# sudo apt -y install software-properties-common
# sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
# sudo add-apt-repository 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.5/ubuntu focal main'
sudo apt install wget
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
echo "b7519209546e1656e5514c04b4dcffdd9b4123201bcd1875a361ad79eb943bbe mariadb_repo_setup" | sha256sum -c -
chmod +x mariadb_repo_setup
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-10.5"
sudo apt update
sudo apt -y install mariadb-server
systemctl status mariadb
mariadbd --print-defaults

# done
exit 0
