#!/bin/bash

cd "${0%/*}/../smartcard-ci"

docker run -it --rm -v `pwd`/scripts:/app/scripts:ro -v `pwd`/../applets:/app/applets:rw -v `pwd`/../bin:/app/bin:rw stargate01/smartcard-ci "$@"
