#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/apex-fido2/target
cd /app/src/applets/apex-fido2
JC_HOME=/app/sdks/jc304_kit ant
cp /app/src/applets/apex-fido2/target/*.cap /app/src/bin/
