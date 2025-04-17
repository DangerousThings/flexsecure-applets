#!/usr/bin/env bash

cd "${0%/*}/../smartcard-ci"

docker run -it --rm -v `pwd`/..:/app/src:rw -v /tmp/smartcard-ci:/tmp:rw vivokey/smartcard-ci:latest "$@"
