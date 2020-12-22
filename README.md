[![Go Report Card](https://goreportcard.com/badge/github.com/spokeywheeler/batcher)](https://goreportcard.com/report/github.com/spokeywheeler/batcher)  [![PkgGoDev](https://pkg.go.dev/badge/github.com/spokeywheeler/batcher)](https://pkg.go.dev/github.com/spokeywheeler/batcher)  [![CircleCI](https://circleci.com/gh/circleci/circleci-docs.svg?style=shield)](https://circleci.com/gh/spokeywheeler/batcher)  [![Release](https://img.shields.io/github/release/golang-standards/project-layout.svg?style=flat-square)](https://github.com/spokeywheeler/batcher/releases/latest)  [![Total alerts](https://img.shields.io/lgtm/alerts/g/SpokeyWheeler/batcher.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/SpokeyWheeler/batcher/alerts/)  [![Language grade: Go](https://img.shields.io/lgtm/grade/go/g/SpokeyWheeler/batcher.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/SpokeyWheeler/batcher/context:go)  [![Codacy Badge](https://app.codacy.com/project/badge/Grade/132d19460c42416bb371f98bb0c94fc6)](https://www.codacy.com/gh/SpokeyWheeler/batcher/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=SpokeyWheeler/batcher&amp;utm_campaign=Badge_Grade)

# batcher

A utility to perform large updates or deletes in batches to improve performance.

## Usage

```
$ ./batcher help
'update', 'delete', 'version' or 'help' subcommand is required
flags:
  -concurrency int
    	concurrency (default 20)
  -database string
    	database name
  -execute
    	execute the operation ('dry-run' only by default)
  -host string
    	host name or IP (default "localhost")
  -password string
    	password
  -portnum string
    	port number
  -set string
    	e.g. 'column_name=value, column_name=value ...' (ignored if provided with delete subcommand)
  -table string
    	table name
  -user string
    	user name
  -where string
    	e.g. 'column=value AND column IS NOT NULL ...'
```

## CAUTION!

This can seriously mess up your day if you get it wrong. Please dry run first to make sure the statement that will run is the one you want!
