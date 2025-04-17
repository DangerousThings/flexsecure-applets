#!/usr/bin/env bash

cd "${0%/*}/../smartcard-ci"

docker build -t vivokey/smartcard-ci:latest .