#!/bin/bash

. ./libs.sh

psql() {
	docker run -i -e PGPASSWORD=btest governmentpaas/psql psql "$@"
}

docker run -p 127.0.0.1:5432:5432 --name btest-postgres -e POSTGRES_USER=btest -e POSTGRES_DB=batchertestdb -e POSTGRES_PASSWORD=btest -td postgres:latest > /dev/null 2>&1
docker pull governmentpaas/psql > /dev/null 2>&1

export SQLCMD0='psql -w -h 172.17.0.2 -p 5432 -U btest -d batchertestdb '
export SQLCMD='psql -w -h 172.17.0.2 -p 5432 -U btest -d batchertestdb -t -A -c '

sleep 1
$SQLCMD "SELECT version();"

printf "Creating test database..."
$SQLCMD0 < postgres1.sql > /dev/null 2>&1
echo "done"

printf "Populating test database..."
$SQLCMD0 < pop_serial.sql > /dev/null 2>&1
$SQLCMD0 < pop_uuid.sql > /dev/null 2>&1
$SQLCMD0 < pop_composite.sql > /dev/null 2>&1

echo "done"
printf "Starting tests"

testcount=0
passcount=0
errorcount=0

pgruntests 5432 "sslmode=disable"

docker kill btest-postgres > /dev/null 2>&1
docker rm btest-postgres > /dev/null 2>&1

echo "done"
echo "PostgreSQL Tests: $testcount Passed: $passcount Failed: $errorcount"
exit $errorcount
