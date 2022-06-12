#!/bin/bash

cd "${0%/*}/../smartcard-ci"

docker run --rm -v `pwd`/..:/app/src:rw stargate01/smartcard-ci "$@"
