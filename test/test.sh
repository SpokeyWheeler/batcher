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

echo "DROP DATABASE IF EXISTS batchertestdb; CREATE DATABASE IF NOT EXISTS batchertestdb; USE batchertestdb; CREATE TABLE IF NOT EXISTS serialtest (pk SERIAL NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));" > batload.sql

for i in {1..1000}
do
	if [ $i -le 100 ]
	then
		s="a"
	else
		s="b"
	fi
	echo "INSERT INTO serialtest (pk, intcol, strcol) VALUES (0, $i, $s);" >> batload.sql
done

# same test but with a UUID key
echo "USE batchertestdb; CREATE TABLE IF NOT EXISTS uuidtest (pk UUID DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY, intcol INT, strcol VARCHAR(20));" >> batload.sql

for i in {1..1000}
do
	if [ $i -le 100 ]
	then
		s="a"
	else
		s="b"
	fi
	echo "INSERT INTO serialtest (intcol, strcol) VALUES ($i, $s);" >> batload.sql
done

# same test but with a composite key
echo "USE batchertestdb; CREATE TABLE IF NOT EXISTS compositetest (pk1 INT NOT NULL, pk2 VARCHAR(10) NOT NULL, intcol INT, strcol VARCHAR(20));" >> batload.sql

for i in {1..1000}
do
	if [ $i -le 100 ]
	then
		s="a"
	else
		s="b"
	fi
	echo "INSERT INTO serialtest (pk1, pk2, intcol, strcol) VALUES ($i, $s, $i, $s);" >> batload.sql
done


