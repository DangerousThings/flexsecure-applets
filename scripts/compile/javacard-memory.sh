#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/javacard-memory
JC_HOME=/app/sdks/jc304_kit ant dist
cp /app/src/applets/javacard-memory/target/*.cap /app/src/bin/
