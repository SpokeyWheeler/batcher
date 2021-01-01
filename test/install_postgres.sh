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
sudo pg_ctlcluster 13 main start
sudo pg_ctlcluster 13 main status
cat /etc/postgresql/13/main/postgresql.conf
printf "Waiting for PostgreSQL to become available"
while :
do
	psql -w -h localhost -p 5433 -U root -l > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		break
	fi
	printf "."
	sleep 1
done
echo "done"
createuser -d -i -s btest
createdb -U btest -w -h localhost -p 5433 batchertestdb 
# cd -

# done
exit 0
