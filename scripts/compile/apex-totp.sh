#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/apex-totp
JC_HOME=/app/sdks/jc304_kit ant dist
cp /app/src/applets/apex-totp/target/*.cap /app/src/bin/
