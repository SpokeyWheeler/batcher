#!/bin/bash

# fail fast
set -eo pipefail

test/create_pops.sh

. test/libs.sh

export SQLCMD0='psql -h localhost -p 5432 -U btest -d batchertestdb '
export SQLCMD='psql -h localhost -p 5432 -U btest -d batchertestdb -t -A -c '

$SQLCMD "SELECT version();"

printf "Creating test database..."
$SQLCMD0 < test/postgres1.sql > /dev/null 2>&1
echo "done"

printf "Populating test database."
$SQLCMD0 < /tmp/pop_serial.sql > /dev/null 2>&1
printf "."
$SQLCMD0 < /tmp/pop_uuid.sql > /dev/null 2>&1
printf "."
$SQLCMD0 < /tmp/pop_composite.sql > /dev/null 2>&1
echo "done"

testcount=0
passcount=0
errorcount=0

printf "Starting tests"
pgruntests 5432 "sslmode=disable" postgres
echo "done"

echo "PostgreSQL Tests: $testcount Passed: $passcount Failed: $errorcount"
exit $errorcount
