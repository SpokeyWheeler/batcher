#!/bin/bash

# fail fast
# set -eo pipefail

# ./build.sh
test/create_pops.sh

. test/libs.sh
# test/install_mariadb.sh

printf "Waiting for MariaDB to come up"
for i in {1..10}
do
mariadb -hmysql -uroot -pbtestroot --protocol=tcp mysql -e "SHOW DATABASES;" > /dev/null 2>&1
if [ $? -eq 0 ]
then
break
fi
printf "."
sleep 1
done
echo "done"


# mariadb -uroot -pbtestroot --protocol=tcp -P3306 -hmysql mysql -e "SHOW DATABASES;"
mariadb -hmysql -P3306 -uroot -pbtestroot --protocol=tcp mysql -e "SHOW DATABASES;"
SQLCMD0="mariadb mysql -uroot -pbtestroot --protocol=tcp -P3306 -hmysql "
SQLCMD1="mariadb batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hmysql "
SQLCMD="mariadb batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hmysql -e "

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
myruntests 3306 "collation=utf8_general_ci" mariadb
echo "done"

echo "MariaDB Tests: $testcount Passed: $passcount Failed: $errorcount"

exit $errorcount
