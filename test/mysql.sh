#!/bin/bash

# script to run a simple load test for a serial key:
# 1. Generate 1000 rows with known distribution
# 2. Count rows - should be 1000
# 3. Count rows where str column = "a" - should be 100
# 4. Update all rows where str column = "a"
# 5. Count rows where str column = "a" - should be 0
# 6. Delete all rows where int column < 101
# 7. Count all rows - should be 900
# 8. Delete all rows where 1=1
# 7. Count all rows - should be 0

testcount=0
passcount=0
errorcount=0

SQLCMD0="mysql mysql -uroot -pbtestroot --protocol=tcp -P3306 -hlocalhost "
SQLCMD="mysql batchertestdb -s -ubtest -pbtest --protocol=tcp -P3306 -hlocalhost -e"

comp () {

	if [ $2 != $3 ]
	then
		errorcount=$(( errorcount + 1 ))
		printf "F($1: expected $2, got $3)"
	else
		passcount=$(( passcount + 1 ))
		printf "."
		#printf "($1: expected $2, got $3)"
	fi
	testcount=$(( testcount + 1 ))

}

printf "Preparing load script..."
echo "SET NAMES 'utf8' COLLATE 'utf8_general_ci';
SET CHARACTER SET 'utf8';
DROP DATABASE IF EXISTS batchertestdb;
CREATE DATABASE IF NOT EXISTS batchertestdb CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';
USE batchertestdb;
CREATE TABLE IF NOT EXISTS serialtest (pk SERIAL NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));
CREATE TABLE IF NOT EXISTS compositetest (pk1 INT NOT NULL, pk2 VARCHAR(10) NOT NULL, intcol INT, strcol VARCHAR(20), PRIMARY KEY(pk1, pk2));
DROP USER IF EXISTS 'btest'@'localhost';
CREATE USER IF NOT EXISTS 'btest'@'localhost' IDENTIFIED BY 'btest';
GRANT ALL PRIVILEGES ON *.* TO 'btest'@'localhost';
FLUSH PRIVILEGES;" > /tmp/$$.sql

for i in {1..1000}
do
	if [ $i -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO serialtest (intcol, strcol) VALUES ($i, '$s');" >> /tmp/$$.sql
done

# No UUID test as MySQL doesn't support functions for DEFAULT values.

# same test but with a composite key

for i in {1..1000}
do
	if [ $i -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO compositetest (pk1, pk2, intcol, strcol) VALUES ($i, '$s', $i, '$s');" >> /tmp/$$.sql
done

echo "done"
printf "Populating test database..."

time $SQLCMD0 < /tmp/$$.sql > /dev/null 2>&1

echo "done"
printf "Starting tests"

exptot=1000
expa=100

sertot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest;" 2> /dev/null | grep -iv count | grep -iv row )
comp "Initial serial total" $exptot $sertot
sera=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest WHERE strcol = 'a';" 2> /dev/null | grep -iv count | grep -iv row )
comp "Initial serial a" $expa $sera
cmptot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest;" 2> /dev/null | grep -iv count | grep -iv row )
comp "Initial composite total" $exptot $cmptot
cmpa=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest WHERE strcol = 'a' COLLATE 'utf8_general_ci';" 2> /dev/null | grep -iv count | grep -iv row )
comp "Initial composite a" $expa $cmpa

exptot=900
expa=0

../batcher update -concurrency 4 -database batchertestdb -dbtype mysql -host localhost -opts "collation=utf8_general_ci" -password btest -portnum 3306 -table serialtest -set "strcol='b'" -user btest -where "strcol='a'" -execute

sera=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest WHERE strcol = 'a';" 2> /dev/null | grep -iv count | grep -iv row )
comp "Updated serial a" $expa $sera

../batcher delete -concurrency 4 -database batchertestdb -dbtype mysql -host localhost -opts "collation=utf8_general_ci" -password btest -portnum 3306 -table serialtest -user btest -where "intcol<101" -execute

sertot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest;" 2> /dev/null | grep -iv count | grep -iv row )
comp "Small delete serial total" $exptot $sertot

../batcher update -concurrency 4 -database batchertestdb -dbtype mysql -host localhost -opts "collation=utf8_general_ci" -password btest -portnum 3306 -set "strcol='b'"  -table compositetest -user btest -where "strcol='a'" -execute

cmpa=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest WHERE strcol = 'a';" 2> /dev/null | grep -iv count | grep -iv row )
comp "Updated composite a" $expa $cmpa

../batcher delete -concurrency 4 -database batchertestdb -dbtype mysql -host localhost -opts "collation=utf8_general_ci" -password btest -portnum 3306 -table compositetest -user btest -where "intcol<101" -execute

cmptot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest;" 2> /dev/null | grep -iv count | grep -iv row )
comp "Small delete composite total" $exptot $cmptot

exptot=0

../batcher delete -concurrency 4 -database batchertestdb -dbtype mysql -host localhost -opts "collation=utf8_general_ci" -password btest -portnum 3306 -table serialtest -user btest -where "1=1" -execute

sertot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest;" 2> /dev/null | grep -iv count | grep -iv row )
comp "Full delete serial total" $exptot $sertot

../batcher delete -concurrency 4 -database batchertestdb -dbtype mysql -host localhost -opts "collation=utf8_general_ci" -password btest -portnum 3306 -table compositetest -user btest -where "1=1" -execute

cmptot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest;" 2> /dev/null | grep -iv count | grep -iv row )
comp "Full delete composite total" $exptot $cmptot

echo "done"
echo "MySQL Tests: $testcount Passed: $passcount Failed: $errorcount"

exit $errorcount
