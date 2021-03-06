#!/bin/bash

# fail fast
set -eo pipefail

# don't want to muck up my project directory
cd /tmp
rm -rf /tmp/certs
rm -rf /tmp/cockroach*

# official install instructions
# wget -qO- https://binaries.cockroachdb.com/cockroach-v20.2.3.darwin-10.9-amd64.tgz | tar xvz 2> /dev/null
# sudo cp cockroach-v20.2.3.darwin-10.9-amd64/cockroach /usr/local/bin/

# make the certificates
mkdir -p /tmp/certs
cockroach cert create-ca --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-node localhost --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-client root --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key
cockroach cert create-client btest --certs-dir=/tmp/certs --ca-key=/tmp/certs/ca.key

# start it in /tmp so the data files are here
cockroach start-single-node --certs-dir=/tmp/certs --background --listen-addr=localhost 2> /dev/null

# done
exit 0
