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
