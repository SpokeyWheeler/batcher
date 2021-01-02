#!/bin/bash

# fail fast
# set -eo pipefail

# install MariaDB
sudo apt update
sudo apt -y install software-properties-common
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.5/ubuntu focal main'
sudo apt update
sudo apt -y install mariadb-server
systemctl status mariadb
mariadbd --print-defaults

# done
exit 0
