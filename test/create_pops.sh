#!/bin/bash

> pop_serial.sql

for i in {1..1000}
do
	if [ "$i" -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO serialtest (intcol, strcol) VALUES ($i, '$s');" >> pop_serial.sql
done

# same test but with a UUID key

> pop_uuid.sql

for i in {1..1000}
do
	if [ "$i" -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO uuidtest (intcol, strcol) VALUES ($i, '$s');" >> pop_uuid.sql
done

# same test but with a composite key

> pop_composite.sql

for i in {1..1000}
do
	if [ "$i" -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO compositetest (pk1, pk2, intcol, strcol) VALUES ($i, '$s', $i, '$s');" >> pop_composite.sql
done
