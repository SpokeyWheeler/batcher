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

psql -q "postgresql://root@localhost:5432" < /tmp/$$

echo "done"
printf "Starting tests"

exptot=1000
expa=100

sertot=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" )
comp "Initial serial total" $exptot $sertot
sera=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" )
comp "Initial serial a" $expa $sera
uidtot=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" )
comp "Initial UUID total" $exptot $uidtot
uida=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM uuidtest WHERE strcol = 'a';" )
comp "Initial UUID a" $expa $uida
cmptot=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM compositetest;" )
comp "Initial composite total" $exptot $cmptot
cmpa=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" )
comp "Initial composite a" $expa $cmpa

exptot=900
expa=0

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -set "strcol='b'"  -table serialtest -user $DBUSER -where "strcol='a'" -execute

sera=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" )
comp "Updated serial a" $expa $sera

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -table serialtest -user $DBUSER -where "intcol<101" -execute

sertot=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" )
comp "Small delete serial total" $exptot $sertot

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -set "strcol='b'"  -table uuidtest -user $DBUSER -where "strcol='a'" -execute

uida=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM uuidtest WHERE strcol = 'a';" )
comp "Updated UUID a" $expa $uida

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -table uuidtest -user $DBUSER -where "intcol<101" -execute

uidtot=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" )
comp "Small delete UUID total" $exptot $uidtot

../batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -set "strcol='b'"  -table compositetest -user $DBUSER -where "strcol='a'" -execute

cmpa=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" )
comp "Updated composite a" $expa $cmpa

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -table compositetest -user $DBUSER -where "intcol<101" -execute

cmptot=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM compositetest;" )
comp "Small delete composite total" $exptot $cmptot

exptot=0

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -table serialtest -user $DBUSER -where "1=1" -execute

sertot=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM serialtest;" )
comp "Full delete serial total" $exptot $sertot

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -table uuidtest -user $DBUSER -where "1=1" -execute

uidtot=$( psql -q "postgresql://root@localhost:5432" -t -A -c "USE batchertestdb; SELECT COUNT(1) FROM uuidtest;" )
comp "Full delete UUID total" $exptot $uidtot

../batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host localhost -opts "sslmode=require" -password $DBPASSWORD -portnum 5432 -table compositetest -user $DBUSER -where "1=1" -execute

cmptot=$( psql -q "postgresql://root@localhost:5432"USE batchertestdb; SELECT COUNT(1) FROM compositetest;" )
comp "Full delete composite total" $exptot $cmptot

rm /tmp/$$

echo "done"
echo "Tests: $testcount Passed: $passcount Failed: $errorcount"
exit $errorcount
