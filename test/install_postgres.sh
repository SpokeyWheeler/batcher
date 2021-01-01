#!/bin/bash

# fail fast
set -eo pipefail

# don't mess up my project directory
cd /tmp

# put the data in /tmp
mkdir -p /tmp/postgres

# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# install
PGDATABASE=batchertestdb
PGUSER=btest
PGPASSWORD=btest
sudo apt install postgresql-13 postgresql-client-13
sudo pg_ctlcluster 13 main start
sudo pg_ctlcluster 13 main status
sleep 30
sudo pg_ctlcluster 13 main status
cd -

# done
exit 0
