#!/bin/bash

cd "${0%/*}"

./docker-run-image.sh "/app/src/scripts/clean.sh"
