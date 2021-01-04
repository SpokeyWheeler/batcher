#!/bin/bash

# fail fast
# set -eo pipefail

# ./build.sh
test/create_pops.sh

# test/install_postgres.sh

. test/libs.sh

export PGPASS=btest
export SQLCMD0='psql -w -h postgres -p 5432 -U btest -d batchertestdb '
export SQLCMD='psql -w -h postgres -p 5432 -U btest -d batchertestdb -t -A -c '

$SQLCMD "SELECT version();"

printf "Creating test database..."
$SQLCMD0 < test/postgres1.sql # > /dev/null 2>&1
echo "done"

printf "Populating test database."
$SQLCMD0 < /tmp/pop_serial.sql # > /dev/null 2>&1
printf "."
$SQLCMD0 < /tmp/pop_uuid.sql # > /dev/null 2>&1
printf "."
$SQLCMD0 < /tmp/pop_composite.sql # > /dev/null 2>&1
echo "done"

testcount=0
passcount=0
errorcount=0

printf "Starting tests"
pgruntests 5432 "sslmode=disable" postgres
echo "done"

echo "PostgreSQL Tests: $testcount Passed: $passcount Failed: $errorcount"
exit $errorcount
