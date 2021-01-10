#!/bin/bash

> /tmp/pop_serial.sql

for i in {1..1000}
do
	if [ "$i" -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO serialtest VALUES (0, $i, '$s');" >> /tmp/pop_serial.sql
done

# same test but with a composite key

> /tmp/pop_composite.sql

for i in {1..1000}
do
	if [ "$i" -le 100 ]
	then
		s='a'
	else
		s='b'
	fi
	echo "INSERT INTO compositetest (pk1, pk2, intcol, strcol) VALUES ($i, '$s', $i, '$s');" >> /tmp/pop_composite.sql
done
