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

mkdir -p /tmp/certs
cockroach cert create-ca --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-node localhost --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-client root --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-client btest --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
# cockroach cert list --certs-dir=/tmp/certs
cockroach start-single-node --certs-dir=/tmp/certs --background --listen-addr=localhost 2> /dev/null

testcount=0
passcount=0
errorcount=0

SQLCMD0="cockroach sql --url=postgres://root@localhost:26257/postgres?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.root.crt&sslkey=/tmp/certs/client.root.key "
SQLCMD="cockroach sql --url=postgres://btest:btest@localhost:26257/postgres?sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key --format tsv -e "

comp () {

	if [ "$2" != "$3" ]
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
echo "DROP DATABASE IF EXISTS batchertestdb;
CREATE DATABASE IF NOT EXISTS batchertestdb;
USE batchertestdb;
CREATE USER btest WITH PASSWORD 'btest';
GRANT admin TO btest;
CREATE TABLE IF NOT EXISTS serialtest (pk SERIAL NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));" > /tmp/$$

for i in {1..1000}
do
	if [ "$i" -le 100 ]
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
	if [ "$i" -le 100 ]
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
	if [ "$i" -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO compositetest (pk1, pk2, intcol, strcol) VALUES ($i, '$s', $i, '$s');" >> /tmp/$$
done

echo "done"
printf "Populating test database..."

$SQLCMD0 < /tmp/$$ > /dev/null 2>&1

echo "done"
printf "Starting tests"

exptot=1000
expa=100

sertot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" | grep -iv count | grep -iv row | tr -d '\r' | tr -d '\r' )
comp "Initial serial total" "$exptot" "$sertot"
sera=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Initial serial a" "$expa" "$sera"
uidtot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Initial UUID total" "$exptot" "$uidtot"
uida=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM uuidtest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Initial UUID a" "$expa" "$uida"
cmptot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM compositetest;" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Initial composite total" "$exptot" "$cmptot"
cmpa=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Initial composite a" "$expa" "$cmpa"

exptot=900
expa=0

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -table serialtest -set "strcol='b'" -user btest -where "strcol='a'" -execute

sera=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Updated serial a" "$expa" "$sera"

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -table serialtest -user btest -where "intcol<101" -execute

sertot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Small delete serial total" "$exptot" "$sertot"

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -set "strcol='b'"  -table uuidtest -user btest -where "strcol='a'" -execute

uida=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM uuidtest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Updated UUID a" "$expa" "$uida"

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -table uuidtest -user btest -where "intcol<101" -execute

uidtot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Small delete UUID total" "$exptot" "$uidtot"

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -set "strcol='b'"  -table compositetest -user btest -where "strcol='a'" -execute

cmpa=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Updated composite a" "$expa" "$cmpa"

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -table compositetest -user btest -where "intcol<101" -execute

cmptot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM compositetest;" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Small delete composite total" "$exptot" "$cmptot"

exptot=0

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -table serialtest -user btest -where "1=1" -execute

sertot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Full delete serial total" "$exptot" "$sertot"

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -table uuidtest -user btest -where "1=1" -execute

uidtot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Full delete UUID total" "$exptot" "$uidtot"

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=verify-ca&sslrootcert=/tmp/certs/ca.crt&sslcert=/tmp/certs/client.btest.crt&sslkey=/tmp/certs/client.btest.key" -password btest -portnum 26257 -table compositetest -user btest -where "1=1" -execute

cmptot=$( $SQLCMD "USE batchertestdb; SELECT COUNT(1) FROM compositetest;" | grep -iv count | grep -iv row | tr -d '\r' )
comp "Full delete composite total" "$exptot" "$cmptot"

echo "done"
echo "CockroachDB Tests: $testcount Passed: $passcount Failed: $errorcount"
cockroach quit --certs-dir=/tmp/certs 2> /dev/null

exit $errorcount
