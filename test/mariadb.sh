#!/bin/bash

# fail fast
# set -eo pipefail

./build.sh
test/create_pops.sh

. test/libs.sh
test/install_mariadb.sh

# SQLCMD0="mysql mysql -uroot -pbtestroot --protocol=tcp -P3306 -hlocalhost "
# SQLCMD0="sudo mysql mysql -uroot -w --protocol=tcp -P3306 -hlocalhost "
# SQLCMD0="mariadb mysql -umysql -w --protocol=tcp -P3306 -hlocalhost "
# SQLCMD1="mariadb batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hlocalhost "
# SQLCMD="mariadb batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hlocalhost -e "
SQLCMD0="sudo mariadb mysql -uroot -w --protocol=tcp -P3306 -h127.0.0.1 "
SQLCMD1="mariadb batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -h127.0.0.1 "
SQLCMD="mariadb batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -h127.0.0.1 -e "

testcount=0
passcount=0
errorcount=0

printf "Creating test database..."
$SQLCMD0 < test/mysql1.sql # > /dev/null 2>&1
echo "done"

printf "Populating test database."
$SQLCMD1 < /tmp/pop_serial.sql # > /dev/null 2>&1
printf "."
$SQLCMD1 < /tmp/pop_composite.sql # > /dev/null 2>&1
echo ".done"

printf "Starting tests"
myruntests 3306 "collation=utf8_general_ci"
echo "done"

echo "MariaDB Tests: $testcount Passed: $passcount Failed: $errorcount"

exit $errorcount
