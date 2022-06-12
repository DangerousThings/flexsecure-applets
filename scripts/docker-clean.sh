#!/bin/bash

cd "${0%/*}"

./docker-run.sh "/app/src/scripts/clean.sh"
