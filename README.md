[![Go Report Card](https://goreportcard.com/badge/github.com/spokeywheeler/batcher)](https://goreportcard.com/report/github.com/spokeywheeler/batcher)  [![PkgGoDev](https://pkg.go.dev/badge/github.com/spokeywheeler/batcher)](https://pkg.go.dev/github.com/spokeywheeler/batcher)  ![Go](https://github.com/SpokeyWheeler/batcher/workflows/Go/badge.svg?branch=main) [![Total alerts](https://img.shields.io/lgtm/alerts/g/SpokeyWheeler/batcher.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/SpokeyWheeler/batcher/alerts/)  [![Codacy Badge](https://app.codacy.com/project/badge/Grade/132d19460c42416bb371f98bb0c94fc6)](https://www.codacy.com/gh/SpokeyWheeler/batcher/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=SpokeyWheeler/batcher&amp;utm_campaign=Badge_Grade)  [![code-inspector Badge](https://www.code-inspector.com/project/17296/score/svg)](https://www.code-inspector.com/project/17296/score/svg)  [![GuardRails badge](https://api.guardrails.io/v2/badges/SpokeyWheeler/batcher.svg?token=d09c361974cb1acab7d58f925c6a7dd6f9fc6c05dfd43904043a06f382cdc4d7&provider=github)](https://dashboard.guardrails.io/gh/SpokeyWheeler/52652)  [![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)  [![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/spokeywheeler/batcher.svg)](http://isitmaintained.com/project/spokeywheeler/batcher "Average time to resolve an issue")  [![Percentage of issues still open](http://isitmaintained.com/badge/open/spokeywheeler/batcher.svg)](http://isitmaintained.com/project/spokeywheeler/batcher "Percentage of issues still open")

# batcher

A utility to perform large updates or deletes in batches to improve performance. `TRUNCATE TABLE` is obviously a faster way to purge an entire table, but in many cases, you have an enormous table, of which you need to remove or update a chunk. Copying the rows you want to keep (for a mass delete) can have all sorts of referential constraint issues.

After testing many different approaches, I've created this, which generates singleton updates or deletes of the rows in question. If you want to, you can output the generated SQL to a flat file and process it in some other way. If you use the `-execute` option, batcher will use Go's internal concurrency to perform your mass update without having to worry about long transactions or the excruciating slowness of some databases when doing set operations.

No names, no packdrill.

## Usage

```bash
$ ./batcher
'update', 'delete', 'version' or 'help' subcommand is required
flags:
  -concurrency int
    	concurrency (default 20)
  -database string
    	database name
  -dbtype string
    	database type, e.g. postgres, informix, oracle, mysql (default "postgres")
  -execute
    	execute the operation ('dry-run' only by default)
  -host string
    	host name or IP (default "localhost")
  -opts string
    	JDBC URL options (e.g. sslmode=disable) (default "sslmode=require")
  -password string
    	password
  -portnum string
    	port number (default "26257")
  -set string
    	e.g. 'column_name=value, column_name=value ...' (ignored if provided with delete subcommand)
  -table string
    	table name
  -user string
    	user name
  -verbose
    	provide detailed output (will output all statements to the screen)
  -where string
    	e.g. 'column=value AND column IS NOT NULL ...'
```

## CAUTION

This can seriously mess up your day if you get it wrong. Please dry run first to make sure the statement that will run is the one you want!
