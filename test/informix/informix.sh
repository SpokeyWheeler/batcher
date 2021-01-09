#!/bin/bash

# fail fast
# set -eo pipefail


comp() {
	if [ "$2" != "$3" ]
	then
		errorcount=$(( errorcount + 1 ))
		printf "F($1: expected $2, got $3)"
	else
		passcount=$(( passcount + 1 ))
		printf "."
		# printf "($1: expected $2, got $3)"
	fi
	testcount=$(( testcount + 1 ))
}

ixruntests() {
	portnum=$1
	opts=$2
        host=$3

	exptot=1000
	expa=100

	sertot=$( echo "SELECT COUNT(1) FROM serialtest;" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Initial serial total" "$exptot" "$sertot"

	sera=$( echo "SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Initial serial a" "$expa" "$sera"

	cmptot=$( echo "SELECT COUNT(1) FROM compositetest;" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Initial composite total" "$exptot" "$cmptot"

	cmpa=$( echo "SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Initial composite a" "$expa" "$cmpa"

        exptot=900
	expa=0

	/opt/ibm/scripts/batcher update -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password btest -portnum $portnum -table serialtest -set "strcol='b'" -user btest -where "strcol='a'" -execute

	sera=$( echo "SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Updated serial a" "$expa" "$sera"

	/opt/ibm/scripts/batcher delete -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password btest -portnum $portnum -table serialtest -user btest -where "intcol<101" -execute

	sertot=$( echo "SELECT COUNT(1) FROM serialtest;" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Small delete serial total" "$exptot" "$sertot"

	/opt/ibm/scripts/batcher update -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password btest -portnum $portnum -set "strcol='b'"  -table compositetest -user btest -where "strcol='a'" -execute

	cmpa=$( echo "SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Updated composite a" "$expa" "$cmpa"

	/opt/ibm/scripts/batcher delete -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password btest -portnum $portnum -table compositetest -user btest -where "intcol<101" -execute

	cmptot=$( echo "SELECT COUNT(1) FROM compositetest;" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Small delete composite total" "$exptot" "$cmptot"

	exptot=0

	/opt/ibm/scripts/batcher delete -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password btest -portnum $portnum -table serialtest -user btest -where "1=1" -execute

	sertot=$( echo "SELECT COUNT(1) FROM serialtest;" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Full delete serial total" "$exptot" "$sertot"

	/opt/ibm/scripts/batcher delete -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password btest -portnum $portnum -table compositetest -user btest -where "1=1" -execute

	cmptot=$( echo "SELECT COUNT(1) FROM compositetest;" | $SQLCMD | grep -iv count | grep -iv row )
	comp "Full delete composite total" "$exptot" "$cmptot"
}

/opt/ibm/scripts/informix.pops.sh

export SQLCMD0='dbaccess - '
export SQLCMD='dbaccess batchertestdb '

printf "Creating test database..."
$SQLCMD0 /opt/ibm/scripts/informix1.sql > /dev/null 2>&1
echo "done"

printf "Populating test database."
$SQLCMD /tmp/pop_serial.sql > /dev/null 2>&1
printf "."
$SQLCMD /tmp/pop_composite.sql > /dev/null 2>&1
echo ".done"

testcount=0
passcount=0
errorcount=0

printf "Starting tests"
ixruntests 9088 "" localhost
echo "done"

echo "Informix Tests: $testcount Passed: $passcount Failed: $errorcount"
exit $errorcount
