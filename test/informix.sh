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

	sertot=$( echo "SELECT COUNT(1) FROM serialtest;" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Initial serial total" "$exptot" "$sertot"

	sera=$( echo "SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Initial serial a" "$expa" "$sera"

	cmptot=$( echo "SELECT COUNT(1) FROM compositetest;" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Initial composite total" "$exptot" "$cmptot"

	cmpa=$( echo "SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Initial composite a" "$expa" "$cmpa"

        exptot=900
	expa=0

	./batcher update -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password in4mix -portnum $portnum -table serialtest -set "strcol='b'" -user informix -where "strcol='a'" -execute

	sera=$( echo "SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Updated serial a" "$expa" "$sera"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password in4mix -portnum $portnum -table serialtest -user informix -where "intcol<101" -execute

	sertot=$( echo "SELECT COUNT(1) FROM serialtest;" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Small delete serial total" "$exptot" "$sertot"

	./batcher update -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password in4mix -portnum $portnum -set "strcol='b'"  -table compositetest -user informix -where "strcol='a'" -execute

	cmpa=$( echo "SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Updated composite a" "$expa" "$cmpa"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password in4mix -portnum $portnum -table compositetest -user informix -where "intcol<101" -execute

	cmptot=$( echo "SELECT COUNT(1) FROM compositetest;" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Small delete composite total" "$exptot" "$cmptot"

	exptot=0

	./batcher delete -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password in4mix -portnum $portnum -table serialtest -user informix -where "1=1" -execute

	sertot=$( echo "SELECT COUNT(1) FROM serialtest;" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Full delete serial total" "$exptot" "$sertot"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype informix -host $host -opts $opts -password in4mix -portnum $portnum -table compositetest -user informix -where "1=1" -execute

	cmptot=$( echo "SELECT COUNT(1) FROM compositetest;" | $SQLCMD 2> /dev/null | grep -iv count | grep -iv row | grep -v "^$" | awk '{print $1}' )
	comp "Full delete composite total" "$exptot" "$cmptot"
}

export SQLCMD='docker exec -i informix dbaccess batchertestdb '

testcount=0
passcount=0
errorcount=0

printf "Starting tests"
ixruntests 9088 "" localhost
echo "done"

echo "Informix Tests: $testcount Passed: $passcount Failed: $errorcount"
exit $errorcount
