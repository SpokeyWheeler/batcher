## v0.10.3 (2021-01-11)

### Fix

- **mariadb/mysql**: fix tests

## v0.10.2 (2021-01-11)

### Fix

- **postgres**: fix tests

## v0.10.1 (2021-01-11)

### Fix

- **cockroach**: revert test changes

## v0.10.0 (2021-01-11)

### Feat

- **cockroach**: get user name from sslcert if empty user is giver

## v0.9.1 (2021-01-11)

### Fix

- **readme**: basically, I want to force a version bump

## v0.9.0 (2021-01-11)

### Feat

- **databases**: focus on open source tests

## v0.8.14 (2021-01-10)

### Fix

- **informix**: fix a tupo

## v0.8.13 (2021-01-10)

### Fix

- **ci**: implement learnings from running in container

## v0.8.12 (2021-01-10)

### Fix

- **informix**: network option

## v0.8.11 (2021-01-10)

### Fix

- **ci**: implement the host network for dbaccess

## v0.8.10 (2021-01-10)

### Fix

- **informix**: stop fast fail

## v0.8.9 (2021-01-10)

### Fix

- **ci**: remove root password from create database script

## v0.8.8 (2021-01-09)

### Fix

- **mysql**: typo

## v0.8.7 (2021-01-09)

### Fix

- **mysql**: make hostname changes to mysql runner and driver

## v0.8.6 (2021-01-09)

### Fix

- **postgres**: batcher driver needs changing too

## v0.8.5 (2021-01-09)

### Fix

- **postgres**: create new runner for version query

## v0.8.4 (2021-01-09)

### Fix

- **postgres**: first script has to run as root

## v0.8.3 (2021-01-09)

### Fix

- **postgres**: another script had the wrong hostname

## v0.8.2 (2021-01-09)

### Fix

- **postgres**: change script from buddy to semaphore

## v0.8.1 (2021-01-09)

### Fix

- **cockroach**: cp needs sudo

## v0.8.0 (2021-01-09)

### Feat

- **informix**: start adding support

## v0.7.40 (2021-01-05)

### Fix

  - **goreleaser**: remove docker build

## v0.7.39 (2021-01-04)

### Fix

  - **buddy**: remove diagnostics

## v0.7.38 (2021-01-04)

### Fix

  - **version**: just to bump the version

## v0.7.37 (2021-01-04)

### Fix

  - **gorelease**: add --rm-dist flag

## v0.7.36 (2021-01-04)

### Fix

  - **gorelease**: add --rm-dist flag

## v0.7.35 (2021-01-04)

### Fix

  - **goreleaser**: diagnostics

## v0.7.34 (2021-01-04)

### Fix

  - **goreleaser**: rm split.sh

## v0.7.33 (2021-01-04)

### Fix

  - **goreleaser**: hard reset of git

## v0.7.32 (2021-01-04)

### Fix

  - **goreleaser**: diags

## v0.7.31 (2021-01-04)

### Fix

  - **postgres**: Use correct variable

## v0.7.30 (2021-01-04)

### Fix

  - **postgres**: fix PGPASS
  - **postgres**: run queries as btest

## v0.7.29 (2021-01-04)

### Fix

  - **mysql**: use password for first sql

## v0.7.28 (2021-01-03)

### Fix

  - **maria**: missed a -h

## v0.7.27 (2021-01-03)

### Fix

  - **maria**: fixed wait

## v0.7.26 (2021-01-03)

### Fix

  - **mariadb**: wait for it

## v0.7.25 (2021-01-03)

### Fix

  - **buddy**: change scripts for different ci approach

## v0.7.24 (2021-01-03)

### Fix

  - **buddy**: executable is now in current directory

## v0.7.23 (2021-01-03)

### Fix

  - **buddy**: pop scripts still need running

## v0.7.22 (2021-01-03)

### Fix

  - **buddy**: sudo not allowed

## v0.7.21 (2021-01-03)

### Fix

  - **buddy**: build no longer needed

## v0.7.20 (2021-01-03)

### Fix

  - **mariadb**: quit vi, again
  - **mariadb**: bind to 0.0.0.0
  - **mariadb**: quit vi

## v0.7.19 (2021-01-03)

### Fix

  - **mariadb**: bind to 0.0.0.0

## v0.7.18 (2021-01-03)

### Fix

  - **mariadb**: quit vi
  - **mariadb**: test database access
  - **mariadb**: tell docker which image to run

## v0.7.15 (2021-01-03)

### Fix

  - **postgres**: provide diagnostics
  - **postgres**: grant more permissions
  - **postgres**: grant permissions
  - **postgres**: simplify initial sql
  - **postgres**: run first script as root

## v0.7.10 (2021-01-03)

### Fix

  - **postgres**: start implementing postgres tests
  - **mysql**: allow btest to access from any server

## v0.7.9 (2021-01-03)

### Fix

  - **travis**: need to use their v2 deployer

## v0.7.8 (2021-01-03)

### Fix

  - **docker**: use a multi-stage build of the Docker image for portability

## v0.7.7 (2021-01-02)

### Fix

  - **goreleaser**: use the suggested Docker process

## v0.7.6 (2021-01-02)

### Fix

  - **goreleaser**: remove license from goreleaser

## v0.7.5 (2021-01-02)

### Fix

  - **goreleaser**: always attempt release

## v0.7.4 (2021-01-02)

### Fix

  - **cz**: remove redundant config

## v0.7.3 (2021-01-02)

### Fix

  - **testing**: travis doesn't like Maria, so I'm dropping it for now
  - Merge branch 'main' of github.com:SpokeyWheeler/batcher into main
  - remove CircleCI config
  - Remove CircleCI badge
  - Start migration to GitHub Actions
  - son of sort out tagging again
  - sort out tagging again
  - restructure goreleaser YAML as per docs
  - start taken Informix out again - rethink needed
  - start adding Informix in
  - Switch to custom MariaDB container - port/basedir
  - Use private email
  - Commit requires config
  - Commit in the CI changes to dependency files

### Feat

  - Add Docker release
  - Add MariaDB to the mix

## v0.6.16 (2020-12-27)

### Fix

  - Track git status

## v0.6.15 (2020-12-27)

### Fix

  - Track git status

## v0.6.14 (2020-12-27)

### Fix

  - Enhance gitignore

## v0.6.13 (2020-12-27)

### Fix

  - Address some code-inspector violations
  - forgot path
  - Attach workspace still needs svu
  - Attach workspace
  - Attach workspace
  - Remove go.mod

## v0.6.12 (2020-12-27)

### Fix

  - Add bin directory to gitignore

## v0.6.11 (2020-12-27)

### Fix

  - Different tag push

## v0.6.10 (2020-12-27)

### Fix

  - For some reason, CircleCI doesn't have ~/bin in its path

## v0.6.9 (2020-12-27)

### Fix

  - Should be a string comparison
  - Stop using the goreleaser orb

## v0.6.8 (2020-12-27)

### Fix

  - It should just be checkout, not run checkout
  - It should just be checkout, not run checkout
  - More config refactoring :'(

## v0.6.7 (2020-12-27)

### Fix

  - Do still need checkout though

## v0.6.6 (2020-12-27)

### Fix

  - Do still need checkout though

## v0.6.5 (2020-12-27)

### Fix

  - Remove codecov as no tests

## v0.6.4 (2020-12-27)

### Fix

  - Remove cruft crom the config
  - Remove cruft crom the config

## v0.6.3 (2020-12-27)

### Fix

  - Test config simplification
  - More config refactoring

## v0.6.2 (2020-12-27)

### Fix

  - Capitalisation in badge

## v0.6.1 (2020-12-27)

### Fix

  - Update Go to 1.15.6 everywhere in config

## v0.6.0 (2020-12-27)

### Feat

  - add Sonarcloud.io

## v0.5.10 (2020-12-27)

### Fix

  - Address bug in config.yaml
  - Refactor CI sequencing further

## v0.5.9 (2020-12-27)

### Fix

  - Refactor CI sequencing further

## v0.5.8 (2020-12-27)

### Fix

  - Refactor CI sequencing

## v0.5.7 (2020-12-27)

### Fix

  - Improve CI sequencing

## v0.5.6 (2020-12-27)

### Fix

  - Refactor goreleaser config some more

## v0.5.5 (2020-12-27)

### Fix

  - Refactor goreleaser config

## v0.5.4 (2020-12-27)

### Fix

  - Remove redundant goreleaser config

## v0.5.3 (2020-12-27)

### Fix

  - GoReleaser orb

## v0.5.2 (2020-12-26)

### Fix

  - all tag-related stuff in one run
  - add git tag in CI ... doh
  - remove process.yml
  - Refactor shell scripts to reduce duplication
  - reorder Postgres CREATEs

## v0.4.0 (2020-12-25)

### Fix

  - disable dry-run mode and pray to Knuth
  - replace deprecated config

### Feat

  - Add SVU for automated semantic versioning

## v0.1.0-alpha (2020-12-07)
## v0.7.17 (2021-01-03)

### Fix

  - **mariadb**: test database access

## v0.7.16 (2021-01-03)

### Fix

  - **mariadb**: tell docker which image to run
  - **postgres**: provide diagnostics

## v0.7.14 (2021-01-03)

### Fix

  - **postgres**: grant more permissions

## v0.7.13 (2021-01-03)

### Fix

  - **postgres**: grant permissions

## v0.7.12 (2021-01-03)

### Fix

  - **postgres**: simplify initial sql

## v0.7.11 (2021-01-03)

### Fix

  - **postgres**: run first script as root
  - **postgres**: start implementing postgres tests
  - **mysql**: allow btest to access from any server
  - **travis**: need to use their v2 deployer
  - **docker**: use a multi-stage build of the Docker image for portability
  - **goreleaser**: use the suggested Docker process
  - **goreleaser**: remove license from goreleaser

## v0.7.5 (2021-01-02)

### Fix

  - **goreleaser**: always attempt release

## v0.7.4 (2021-01-02)

### Fix

  - **cz**: remove redundant config

## v0.7.3 (2021-01-02)

### Fix

  - **testing**: travis doesn't like Maria, so I'm dropping it for now
  - Merge branch 'main' of github.com:SpokeyWheeler/batcher into main
  - remove CircleCI config
  - Remove CircleCI badge
  - Start migration to GitHub Actions
  - son of sort out tagging again
  - sort out tagging again
  - restructure goreleaser YAML as per docs
  - start taken Informix out again - rethink needed
  - start adding Informix in
  - Switch to custom MariaDB container - port/basedir
  - Use private email
  - Commit requires config
  - Commit in the CI changes to dependency files

### Feat

  - Add Docker release
  - Add MariaDB to the mix

## v0.6.16 (2020-12-27)

### Fix

  - Track git status

## v0.6.15 (2020-12-27)

### Fix

  - Track git status

## v0.6.14 (2020-12-27)

### Fix

  - Enhance gitignore

## v0.6.13 (2020-12-27)

### Fix

  - Address some code-inspector violations
  - forgot path
  - Attach workspace still needs svu
  - Attach workspace
  - Attach workspace
  - Remove go.mod

## v0.6.12 (2020-12-27)

### Fix

  - Add bin directory to gitignore

## v0.6.11 (2020-12-27)

### Fix

  - Different tag push

## v0.6.10 (2020-12-27)

### Fix

  - For some reason, CircleCI doesn't have ~/bin in its path

## v0.6.9 (2020-12-27)

### Fix

  - Should be a string comparison
  - Stop using the goreleaser orb

## v0.6.8 (2020-12-27)

### Fix

  - It should just be checkout, not run checkout
  - It should just be checkout, not run checkout
  - More config refactoring :'(

## v0.6.7 (2020-12-27)

### Fix

  - Do still need checkout though

## v0.6.6 (2020-12-27)

### Fix

  - Do still need checkout though

## v0.6.5 (2020-12-27)

### Fix

  - Remove codecov as no tests

## v0.6.4 (2020-12-27)

### Fix

  - Remove cruft crom the config
  - Remove cruft crom the config

## v0.6.3 (2020-12-27)

### Fix

  - Test config simplification
  - More config refactoring

## v0.6.2 (2020-12-27)

### Fix

  - Capitalisation in badge

## v0.6.1 (2020-12-27)

### Fix

  - Update Go to 1.15.6 everywhere in config

## v0.6.0 (2020-12-27)

### Feat

  - add Sonarcloud.io

## v0.5.10 (2020-12-27)

### Fix

  - Address bug in config.yaml
  - Refactor CI sequencing further

## v0.5.9 (2020-12-27)

### Fix

  - Refactor CI sequencing further

## v0.5.8 (2020-12-27)

### Fix

  - Refactor CI sequencing

## v0.5.7 (2020-12-27)

### Fix

  - Improve CI sequencing

## v0.5.6 (2020-12-27)

### Fix

  - Refactor goreleaser config some more

## v0.5.5 (2020-12-27)

### Fix

  - Refactor goreleaser config

## v0.5.4 (2020-12-27)

### Fix

  - Remove redundant goreleaser config

## v0.5.3 (2020-12-27)

### Fix

  - GoReleaser orb

## v0.5.2 (2020-12-26)

### Fix

  - all tag-related stuff in one run
  - add git tag in CI ... doh
  - remove process.yml
  - Refactor shell scripts to reduce duplication
  - reorder Postgres CREATEs

## v0.4.0 (2020-12-25)

### Fix

  - disable dry-run mode and pray to Knuth
  - replace deprecated config

### Feat

  - Add SVU for automated semantic versioning

## v0.1.0-alpha (2020-12-07)
