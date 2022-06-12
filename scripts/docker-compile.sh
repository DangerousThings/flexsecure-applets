#!/bin/bash

cd "${0%/*}"

./docker-run.sh "/app/src/scripts/compile.sh"
