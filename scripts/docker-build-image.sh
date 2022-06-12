#!/bin/bash

cd "${0%/*}/../smartcard-ci"

docker build -t stargate01/smartcard-ci .