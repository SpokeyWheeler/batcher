#!/bin/bash

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

pgruntests() {
	portnum=$1
	opts=$2
        host=$3

	exptot=1000
	expa=100

	sertot=$( $SQLCMD "SELECT COUNT(1) FROM serialtest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Initial serial total" "$exptot" "$sertot"

	sera=$( $SQLCMD "SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Initial serial a" "$expa" "$sera"

	uidtot=$( $SQLCMD "SELECT COUNT(1) FROM uuidtest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Initial UUID total" "$exptot" "$uidtot"

	uida=$( $SQLCMD "SELECT COUNT(1) FROM uuidtest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Initial UUID a" "$expa" "$uida"

	cmptot=$( $SQLCMD "SELECT COUNT(1) FROM compositetest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Initial composite total" "$exptot" "$cmptot"

	cmpa=$( $SQLCMD "SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Initial composite a" "$expa" "$cmpa"

        exptot=900
	expa=0

	./batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -table serialtest -set "strcol='b'" -user btest -where "strcol='a'" -execute

	sera=$( $SQLCMD "SELECT COUNT(1) FROM serialtest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Updated serial a" "$expa" "$sera"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -table serialtest -user btest -where "intcol<101" -execute

	sertot=$( $SQLCMD "SELECT COUNT(1) FROM serialtest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Small delete serial total" "$exptot" "$sertot"

	./batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -set "strcol='b'"  -table uuidtest -user btest -where "strcol='a'" -execute

	uida=$( $SQLCMD "SELECT COUNT(1) FROM uuidtest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Updated UUID a" "$expa" "$uida"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -table uuidtest -user btest -where "intcol<101" -execute

	uidtot=$( $SQLCMD "SELECT COUNT(1) FROM uuidtest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Small delete UUID total" "$exptot" "$uidtot"

	./batcher update -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -set "strcol='b'"  -table compositetest -user btest -where "strcol='a'" -execute

	cmpa=$( $SQLCMD "SELECT COUNT(1) FROM compositetest WHERE strcol = 'a';" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Updated composite a" "$expa" "$cmpa"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -table compositetest -user btest -where "intcol<101" -execute

	cmptot=$( $SQLCMD "SELECT COUNT(1) FROM compositetest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Small delete composite total" "$exptot" "$cmptot"

	exptot=0

	./batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -table serialtest -user btest -where "1=1" -execute

	sertot=$( $SQLCMD "SELECT COUNT(1) FROM serialtest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Full delete serial total" "$exptot" "$sertot"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -table uuidtest -user btest -where "1=1" -execute

	uidtot=$( $SQLCMD "SELECT COUNT(1) FROM uuidtest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Full delete UUID total" "$exptot" "$uidtot"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype postgres -host $host -opts $opts -password btest -portnum $portnum -table compositetest -user btest -where "1=1" -execute

	cmptot=$( $SQLCMD "SELECT COUNT(1) FROM compositetest;" | grep -iv count | grep -iv row | tr -d '\r' )
	comp "Full delete composite total" "$exptot" "$cmptot"
}

myruntests() {
	portnum=$1
	opts=$2
	hosts=$3

	exptot=1000
	expa=100

	sertot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest;" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Initial serial total" "$exptot" "$sertot"
	sera=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest WHERE strcol = 'a';" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Initial serial a" "$expa" "$sera"
	cmptot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest;" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Initial composite total" "$exptot" "$cmptot"
	cmpa=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest WHERE strcol = 'a' COLLATE 'utf8_general_ci';" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Initial composite a" "$expa" "$cmpa"

	exptot=900
	expa=0

	./batcher update -concurrency 4 -database batchertestdb -dbtype mysql -host $host -opts $opts -password btest -portnum $portnum -table serialtest -set "strcol='b'" -user btest -where "strcol='a'" -execute

	sera=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest WHERE strcol = 'a';" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Updated serial a" "$expa" "$sera"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype mysql -host $host -opts $opts -password btest -portnum $portnum -table serialtest -user btest -where "intcol<101" -execute

	sertot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest;" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Small delete serial total" "$exptot" "$sertot"

	./batcher update -concurrency 4 -database batchertestdb -dbtype mysql -host $host -opts $opts -password btest -portnum $portnum -set "strcol='b'"  -table compositetest -user btest -where "strcol='a'" -execute

	cmpa=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest WHERE strcol = 'a';" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Updated composite a" "$expa" "$cmpa"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype mysql -host $host -opts $opts -password btest -portnum $portnum -table compositetest -user btest -where "intcol<101" -execute

	cmptot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest;" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Small delete composite total" "$exptot" "$cmptot"

	exptot=0

	./batcher delete -concurrency 4 -database batchertestdb -dbtype mysql -host $host -opts $opts -password btest -portnum $portnum -table serialtest -user btest -where "1=1" -execute

	sertot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM serialtest;" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Full delete serial total" "$exptot" "$sertot"

	./batcher delete -concurrency 4 -database batchertestdb -dbtype mysql -host $host -opts $opts -password btest -portnum $portnum -table compositetest -user btest -where "1=1" -execute

	cmptot=$( $SQLCMD "SET CHARACTER SET 'utf8'; SET NAMES 'utf8' COLLATE 'utf8_general_ci'; SELECT COUNT(*) FROM compositetest;" 2> /dev/null | grep -iv count | grep -iv row )
	comp "Full delete composite total" "$exptot" "$cmptot"
}
