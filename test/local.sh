#!/bin/bash

printf "Preparing for install."
. test/libs.sh
printf "."
test/create_pops.sh
echo ".done"

# install cockroach
printf "Installing CockroachDB..."
test/install_local.sh
echo "done"

cockroach version | grep "Build Tag"

SQLCMD0="cockroach sql --url=postgres://root@localhost:26257/postgres?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.root.crt&sslkey=/tmp/certs/client.root.key "
SQLCMD1="cockroach sql --url=postgres://root@localhost:26257/batchertestdb?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.root.crt&sslkey=/tmp/certs/client.root.key "
SQLCMD="cockroach sql --url=postgres://btest@localhost:26257/batchertestdb?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key --format tsv -e "

printf "Creating test database..."
$SQLCMD0 < test/cockroach1.sql > /dev/null 2>&1
echo "done"

printf "Populating test database."
$SQLCMD1 < /tmp/pop_serial.sql > /dev/null 2>&1
printf "."
$SQLCMD1 < /tmp/pop_uuid.sql > /dev/null 2>&1
printf "."
$SQLCMD1 < /tmp/pop_composite.sql > /dev/null 2>&1
echo "done"

testcount=0
passcount=0
errorcount=0

cd /tmp
printf "Starting tests"
pgruntests 26257 "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" localhost "" ""
echo "done"

echo "CockroachDB Tests: $testcount Passed: $passcount Failed: $errorcount"
cockroach quit --certs-dir=/tmp/certs 2> /dev/null

exit $errorcount
