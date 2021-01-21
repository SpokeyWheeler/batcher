#!/bin/bash
cd /tmp
curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh
cd -
goreleaser --snapshot --skip-publish --rm-dist
