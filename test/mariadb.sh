#!/bin/bash

# fail fast
set -eo pipefail

test/create_pops.sh

. test/libs.sh

mariadb -uroot --protocol=tcp -P3306 -hlocalhost mysql -e "SHOW DATABASES;"
# mariadb -hmysql -P3306 -uroot -pbtestroot --protocol=tcp mysql -e "SHOW DATABASES;"
SQLCMD0="mariadb mysql -uroot --protocol=tcp -P3306 -hlocalhost "
SQLCMD1="mariadb batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hlocalhost "
SQLCMD="mariadb batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hlocalhost -e "

testcount=0
passcount=0
errorcount=0

printf "Creating test database..."
$SQLCMD0 < test/mysql1.sql > /dev/null 2>&1
echo "done"

printf "Populating test database."
$SQLCMD1 < /tmp/pop_serial.sql > /dev/null 2>&1
printf "."
$SQLCMD1 < /tmp/pop_composite.sql > /dev/null 2>&1
echo ".done"

printf "Starting tests"
myruntests 3306 "collation=utf8_general_ci" localhost btest btest
echo "done"

echo "MariaDB Tests: $testcount Passed: $passcount Failed: $errorcount"

exit $errorcount
