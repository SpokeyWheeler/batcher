[![Build Status](https://spokeywheeler.semaphoreci.com/badges/batcher/branches/main.svg?style=shields)](https://spokeywheeler.semaphoreci.com/projects/batcher)  [![Go Report Card](https://goreportcard.com/badge/github.com/SpokeyWheeler/batcher)](https://goreportcard.com/report/github.com/SpokeyWheeler/batcher)  [![PkgGoDev](https://pkg.go.dev/badge/github.com/SpokeyWheeler/batcher)](https://pkg.go.dev/github.com/SpokeyWheeler/batcher)  [![Total alerts](https://img.shields.io/lgtm/alerts/g/SpokeyWheeler/batcher.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/SpokeyWheeler/batcher/alerts/)  [![Codacy Badge](https://app.codacy.com/project/badge/Grade/132d19460c42416bb371f98bb0c94fc6)](https://www.codacy.com/gh/SpokeyWheeler/batcher/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=SpokeyWheeler/batcher&amp;utm_campaign=Badge_Grade)  [![code-inspector Badge](https://www.code-inspector.com/project/17296/score/svg)](https://www.code-inspector.com/project/17296/score/svg)  [![SourceLevel](https://app.sourcelevel.io/github/SpokeyWheeler/-/batcher.svg)](https://app.sourcelevel.io/github/SpokeyWheeler/-/batcher)  [![GuardRails badge](https://api.guardrails.io/v2/badges/SpokeyWheeler/batcher.svg?token=d09c361974cb1acab7d58f925c6a7dd6f9fc6c05dfd43904043a06f382cdc4d7&provider=github)](https://dashboard.guardrails.io/gh/SpokeyWheeler/52652)  [![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

# batcher

A utility to perform large updates or deletes in batches to improve performance. `TRUNCATE TABLE` is obviously a faster way to purge an entire table, but in many cases, you have an enormous table, of which you need to remove or update a chunk. Copying the rows you want to keep (for a mass delete) can have all sorts of referential constraint issues.

After testing many different approaches, I've created this, which generates singleton updates or deletes of the rows in question. If you want to, you can output the generated SQL to a flat file and process it in some other way. If you use the `-execute` option, batcher will use Go's internal concurrency to perform your mass update without having to worry about long transactions or the excruciating slowness of some databases when doing set operations.

No names, no packdrill.

## Inspired by

[pg-batch](https://github.com/gabfl/pg-batch) - Thank you!

## Supported Databases

| Database | Version | Supported | CI Test Status | Notes |
| -------- | ------- | --------- | -------------- | ----- |
| Cockroach | 20.1.3+ | Yes | 20.2.3  | Versions 19.0+ should work |
| Informix | 12.10+ | No | No | Next on the list |
| MariaDB | 10.5+ | Yes | 10.5 | |
| MySQL | 8.0+ | Yes | 8.0.19 | Earlier (5.x) versions don't work |
| Oracle | 12+ | No | No | After Informix |
| PostgreSQL | 13.1+ | Yes | No | CI is an ongoing project |
| SQLServer | 2019 | No | No | Linux will be first, then Windows (maybe!) |

## Installation

Binaries for Mac, Linux and Windows, as well as the source code in zip and tar.gz  can be found [here](https://github.com/SpokeyWheeler/batcher/releases/latest).

If you want to build the source, I used Go 1.15.6.

On Mac, you can also:
```bash
brew tap SpokeyWheeler/tap
brew install batcher
```

If you're into Docker, you can:
```bash
docker run -it spokey/batcher:latest
```

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

## A word about CI

It turns out that SaaS CI across multiple databases is very, very hard! I've tried with CircleCI, GitHub Actions and Travis-CI, and the best I was able to manage was three out of the four I originally aimed for. (Only two are currently supported because I tried Travis last, I could only get two to work and now can't be bothered to go back!)

Must give massive props to CircleCI support - ridiculously prompt and really, really good.

I haven't given up on it, but I'm going to work on that separately because I'm sick of cluttering up this project with hundreds of meaningless CI-related commit messages and version bumps.

Also, from a CI perspective, Cockroach's "download a single binary and put it in your path" approach has been a delight compared to watching hours of APT output before you can test your change. It's not completely PostgreSQL compatible, but if you're considering a new project with lightweight requirements, it could be an interesting option. PostgreSQL itself isn't too bad, but it's still more work. MariaDB is not a drop-in replacement for MySQL, IMHO, because the process followed after an official APT install is different. Both MariaDB and MySQL need to sort out their character set and collation sequence issues, nobody has time for that shit.

-My next stop will be to try Semaphore CI.-
Semaphore CI is amazing: stunningly fast and I managed to get everything working!

## Coming soon

  - Commercial databases!
  - Examples

