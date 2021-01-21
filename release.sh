#!/bin/bash
rm -f split.sh
git describe
cd /tmp
curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh
cd -
/tmp/bin/goreleaser --rm-dist
