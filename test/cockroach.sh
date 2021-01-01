#!/bin/bash

. test/libs.sh

# install cockroach

wget -qO- https://binaries.cockroachdb.com/cockroach-v20.2.3.linux-amd64.tgz | tar xvz
sudo cp -i cockroach-v20.2.3.linux-amd64/cockroach /usr/local/bin/

# set up certs
mkdir -p /tmp/certs
cockroach cert create-ca --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-node localhost --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-client root --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-client btest --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
# cockroach cert list --certs-dir=/tmp/certs
cd $HOME
cockroach start-single-node --certs-dir=/tmp/certs --background --listen-addr=localhost 2> /dev/null
cd -

cockroach version

SQLCMD0="cockroach sql --url=postgres://root@localhost:26257/postgres?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.root.crt&sslkey=/tmp/certs/client.root.key "
SQLCMD1="cockroach sql --url=postgres://root@localhost:26257/batchertestdb?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.root.crt&sslkey=/tmp/certs/client.root.key "
SQLCMD="cockroach sql --url=postgres://btest:btest@localhost:26257/batchertestdb?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key --format tsv -e "

printf "Creating test database..."
$SQLCMD0 < cockroach1.sql > /dev/null 2>&1
echo "done"

printf "Populating test database..."

$SQLCMD1 < pop_serial.sql > /dev/null 2>&1
$SQLCMD1 < pop_uuid.sql > /dev/null 2>&1
$SQLCMD1 < pop_composite.sql > /dev/null 2>&1

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
