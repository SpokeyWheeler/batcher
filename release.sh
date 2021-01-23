#!/bin/bash
rm -f split.sh
git describe
git log -1 | grep "bump:" > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo "Not a release"
	exit 0
fi
cd /tmp
curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh
cd -
/tmp/bin/goreleaser --rm-dist
