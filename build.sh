#!/bin/bash
set -e
set -x
start=`date +%s`
dir=$( dirname $0 )


[ -f /bin/busybox ] || (echo "/bin/busybox is required to build cnt" && exit 1)

[ -f $GOPATH/bin/godep ] || go get github.com/tools/godep

# clean
rm -Rf $dir/dist/*-amd64

# binary
[ -f $GOPATH/bin/go-bindata ] || go get -u github.com/jteeuwen/go-bindata/...
mkdir -p $dir/dist/bindata
[ -f $dir/aci-bats/aci-bats.aci ] || $dir/aci-bats/build.sh
cp $dir/aci-bats/aci-bats.aci $dir/dist/bindata
[ -f $dir/dist/bindata/busybox ] || cp /bin/busybox $dir/dist/bindata/

GOOS=linux GOARCH=amd64 godep go build --ldflags '-extldflags "-static"' -o $dir/dist/bindata/templater github.com/blablacar/cnt/templater

go-bindata -nomemcopy -pkg dist -o $dir/dist/bindata.go $dir/dist/bindata/...

#save dep
godep save ./... || true

# format && test
gofmt -w -s .
godep go test -cover $dir/...


# build
#GOOS=darwin GOARCH=amd64 godep go build -o dist/darwin-amd64/cnt&
#GOOS=windows GOARCH=amd64 godep go build -o dist/windows-amd64/cnt.exe&
GOOS=linux GOARCH=amd64 godep go build -o $dir/dist/linux-amd64/cnt

# install
cp $dir/dist/linux-amd64/cnt $GOPATH/bin/cnt

end=`date +%s`
echo "Duration : $((end-start))s"
