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

# SQLCMD="psql -q \"postgresql://root@localhost:5432\" "
SQLCMD="cockroach sql --insecure --format tsv"

comp () {

	if [ $2 != $3 ]
	then
		errorcount=$(( errorcount + 1 ))
		printf "F($1: expected $2, got $3)"
	else
		passcount=$(( passcount + 1 ))
		printf "."
	fi
	testcount=$(( testcount + 1 ))

}

printf "Preparing load script..."
echo "DROP DATABASE IF EXISTS batchertestdb;
CREATE DATABASE IF NOT EXISTS batchertestdb;
USE batchertestdb;
CREATE USER $DBUSER WITH PASSWORD '$DBPASSWORD';
GRANT admin TO $DBUSER;
CREATE TABLE IF NOT EXISTS serialtest (pk SERIAL NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));" > /tmp/$$

for i in {1..1000}
do
	if [ $i -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO serialtest (intcol, strcol) VALUES ($i, '$s');" >> /tmp/$$
done

# same test but with a UUID key
echo "USE batchertestdb;
CREATE TABLE IF NOT EXISTS uuidtest (pk UUID DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));" >> /tmp/$$

for i in {1..1000}
do
	if [ $i -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO uuidtest (intcol, strcol) VALUES ($i, '$s');" >> /tmp/$$
done

# same test but with a composite key
echo "USE batchertestdb;
CREATE TABLE IF NOT EXISTS compositetest (pk1 INT NOT NULL, pk2 VARCHAR(10) NOT NULL, intcol INT, strcol VARCHAR(20), PRIMARY KEY(pk1, pk2));" >> /tmp/$$

for i in {1..1000}
do
	if [ $i -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO compositetest (pk1, pk2, intcol, strcol) VALUES ($i, '$s', $i, '$s');" >> /tmp/$$
done

echo "done"
printf "Populating test database..."

$SQLCMD < /tmp/$$

echo "done"
printf "Starting tests"

exptot=1000
expa=100

sertot=$( $SQLCMD -e  "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" )
comp "Initial serial total" $exptot $sertot
sera=$( $SQLCMD -e  "USE batchertestdb; SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" )
comp "Initial serial a" $expa $sera
uidtot=$( $SQLCMD -e  "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" )
comp "Initial UUID total" $exptot $uidtot
uida=$( $SQLCMD -e  "USE batchertestdb; SELECT COUNT(1) FROM uuidtest WHERE strcol = 'a';" )
comp "Initial UUID a" $expa $uida
cmptot=$( $SQLCMD -e  "USE batchertestdb; SELECT COUNT(1) FROM compositetest;" )
comp "Initial composite total" $exptot $cmptot
cmpa=$( $SQLCMD -e  "USE batchertestdb; SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" )
comp "Initial composite a" $expa $cmpa

exptot=900
expa=0

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -set "strcol='b'"  -e DBUSER -where "strcol='a'" -execute

sera=$( $SQLCMD -e  "USE batchertestdb; SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" )
comp "Updated serial a" $expa $sera

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -table serialtest -user $DBUSER -where "intcol<101" -execute

sertot=$( $SQLCMD -e "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" )
comp "Small delete serial total" $exptot $sertot

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -set "strcol='b'"  -table uuidtest -user $DBUSER -where "strcol='a'" -execute

uida=$( $SQLCMD -e "USE batchertestdb; SELECT COUNT(1) FROM uuidtest WHERE strcol = 'a';" )
comp "Updated UUID a" $expa $uida

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -table uuidtest -user $DBUSER -where "intcol<101" -execute

uidtot=$( $SQLCMD -e "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" )
comp "Small delete UUID total" $exptot $uidtot

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -set "strcol='b'"  -table compositetest -user $DBUSER -where "strcol='a'" -execute

cmpa=$( $SQLCMD -e "USE batchertestdb; SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" )
comp "Updated composite a" $expa $cmpa

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -table compositetest -user $DBUSER -where "intcol<101" -execute

cmptot=$( $SQLCMD -e "USE batchertestdb; SELECT COUNT(1) FROM compositetest;" )
comp "Small delete composite total" $exptot $cmptot

exptot=0

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -table serialtest -user $DBUSER -where "1=1" -execute

sertot=$( $SQLCMD -e "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" )
comp "Full delete serial total" $exptot $sertot

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -table uuidtest -user $DBUSER -where "1=1" -execute

uidtot=$( $SQLCMD -e "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" )
comp "Full delete UUID total" $exptot $uidtot

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=disable" -password $DBPASSWORD -portnum 26257 -table compositetest -user $DBUSER -where "1=1" -execute

cmptot=$( $SQLCMDUSE batchertestdb; SELECT COUNT(1) FROM compositetest;" )
comp "Full delete composite total" $exptot $cmptot

rm /tmp/$$

echo "done"
echo "Tests: $testcount Passed: $passcount Failed: $errorcount"
exit $errorcount
