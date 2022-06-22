#!/usr/bin/env bash

cd "${0%/*}/../smartcard-ci"

docker run -it --rm -v `pwd`/..:/app/src:rw stargate01/smartcard-ci "$@"
