#!/bin/bash

# fail fast
# set -eo pipefail

# don't mess up my project directory
# cd /tmp

# put the data in /tmp
# mkdir -p /tmp/postgres

# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# install
sudo apt install postgresql-13 postgresql-client-13
export PGUSER=btest
export PGPASSWORD=btest
export PGDATABASE=batchertestdb
sudo pg_ctlcluster 13 main start
sudo pg_ctlcluster 13 main status
# sudo createuser -U postgres -h localhost -p 5433 -w -d -i -s btest
# sudo createdb -U postgres -h localhost -p 5433 -w -O btest batchertestdb 
printf "Waiting for PostgreSQL to become available"
while :
do
	sudo psql -w -h localhost -p 5433 -l # > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		break
	fi
	printf "."
	sleep 1
done
echo "done"
# cd -

# done
exit 0
