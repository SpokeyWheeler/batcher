[![Go Report Card](https://goreportcard.com/badge/github.com/spokeywheeler/batcher)](https://goreportcard.com/report/github.com/spokeywheeler/batcher)  [![PkgGoDev](https://pkg.go.dev/badge/github.com/spokeywheeler/batcher)](https://pkg.go.dev/github.com/spokeywheeler/batcher)  [![CircleCI](https://circleci.com/gh/circleci/circleci-docs.svg?style=shield)](https://circleci.com/gh/spokeywheeler/batcher)  [![Release](https://img.shields.io/github/release/golang-standards/project-layout.svg?style=flat-square)](https://github.com/spokeywheeler/batcher/releases/latest)  [![Total alerts](https://img.shields.io/lgtm/alerts/g/SpokeyWheeler/batcher.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/SpokeyWheeler/batcher/alerts/)  [![Codacy Badge](https://app.codacy.com/project/badge/Grade/132d19460c42416bb371f98bb0c94fc6)](https://www.codacy.com/gh/SpokeyWheeler/batcher/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=SpokeyWheeler/batcher&amp;utm_campaign=Badge_Grade)  [code-inspector Badge](https://www.code-inspector.com/project/17296/score/svg)

# batcher

A utility to perform large updates or deletes in batches to improve performance. `TRUNCATE TABLE` is obviously a faster way to purge an entire table, but in many cases, you have an enormous table, of which you need to remove or update a chunk. Copying the rows you want to keep (for a mass delete) can have all sorts of referential constraint issues.

After testing many different approaches, I've created this, which generates singleton updates or deletes of the rows in question. If you want to, you can output the generated SQL to a flat file and process it in some other way. If you use the `-execute` option, batcher will use Go's internal concurrency to perform your mass update without having to worry about long transactions or the excruciating slowness of some databases when doing set operations.

No names, no packdrill.

## Usage

```bash
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

## CAUTION

This can seriously mess up your day if you get it wrong. Please dry run first to make sure the statement that will run is the one you want!
