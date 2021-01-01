#!/bin/bash

pwd

./build.sh
test/create_pops.sh

. test/libs.sh

pwd

# install cockroach
test/install_cockroach.sh

cockroach version | grep "Build Tag" | awk '{print $3}'

pwd

SQLCMD0="cockroach sql --url=postgres://root@localhost:26257/postgres?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.root.crt&sslkey=/tmp/certs/client.root.key "
SQLCMD1="cockroach sql --url=postgres://root@localhost:26257/batchertestdb?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.root.crt&sslkey=/tmp/certs/client.root.key "
SQLCMD="cockroach sql --url=postgres://btest:btest@localhost:26257/batchertestdb?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key --format tsv -e "

printf "Creating test database..."
$SQLCMD0 < test/cockroach1.sql > /dev/null 2>&1
echo "done"

printf "Populating test database..."

$SQLCMD1 < test/pop_serial.sql > /dev/null 2>&1
$SQLCMD1 < test/pop_uuid.sql > /dev/null 2>&1
$SQLCMD1 < test/pop_composite.sql > /dev/null 2>&1

echo "done"

testcount=0
passcount=0
errorcount=0

printf "Starting tests"

pgruntests 26257 "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key"

echo "done"
echo "CockroachDB Tests: $testcount Passed: $passcount Failed: $errorcount"
cockroach quit --certs-dir=/tmp/certs 2> /dev/null

exit $errorcount
