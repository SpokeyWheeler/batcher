git status
#git reset --hard
cd /tmp
curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh
cd -
/tmp/bin/goreleaser
