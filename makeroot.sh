#!/bin/bash
set -o errexit -o pipefail -o nounset

rm -rf root
mkdir root

cp test.sh root/test.sh

if ! grep -q "32-bit" <(file ~/workspace/lifecycle/out/linux/lifecycle/lifecycle); then
pushd ~/workspace/lifecycle
GOARCH=386 GOOS=linux LINUX_COMPILATION_IMAGE=i386/golang:1.15-alpine make build-linux-lifecycle
popd
fi

cp ~/workspace/lifecycle/out/linux/lifecycle/lifecycle root/lifecycle

GOARCH=386 GOOS=linux go build -o root/registry github.com/google/go-containerregistry/cmd/registry
GOARCH=386 GOOS=linux go build -o root/crane github.com/google/go-containerregistry/cmd/crane
