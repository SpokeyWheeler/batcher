#!/bin/bash

# fail fast
set -eo pipefail

test/create_pops.sh

. test/libs.sh

testcount=0
passcount=0
errorcount=0

# SQLCMD0="mysql mysql -uroot -pbtestroot --protocol=tcp -P3306 -hlocalhost "
# SQLCMD0="mysql mysql -ubtest -pbtest --protocol=tcp -P3306 -hlocalhost "
SQLCMD0="mysql batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hlocalhost "
SQLCMD="mysql batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hlocalhost -e "

printf "Creating test database..."
$SQLCMD0 < test/mysql1.sql # > /dev/null 2>&1
echo "done"

printf "Populating test database..."
$SQLCMD0 < /tmp/pop_serial.sql # > /dev/null 2>&1
$SQLCMD0 < /tmp/pop_composite.sql # > /dev/null 2>&1
echo "done"

printf "Starting tests"
myruntests 3306 "collation=utf8_general_ci" localhost
echo "done"

echo "MySQL Tests: $testcount Passed: $passcount Failed: $errorcount"

exit $errorcount
