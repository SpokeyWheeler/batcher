[![Go Report Card](https://goreportcard.com/badge/github.com/spokeywheeler/batcher)](https://goreportcard.com/report/github.com/spokeywheeler/batcher)  [![PkgGoDev](https://pkg.go.dev/badge/github.com/spokeywheeler/batcher)](https://pkg.go.dev/github.com/spokeywheeler/batcher)  [![Release](https://img.shields.io/github/release/golang-standards/project-layout.svg?style=flat-square)](https://github.com/spokeywheeler/batcher/releases/latest)

# batcher

A utility to perform large updates or deletes in batches to improve performance.

## Usage

```
$ ./batcher help
'update', 'delete', 'version' or 'help' subcommand is required
flags:
  -batch int
    	batch size (default 100)
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
