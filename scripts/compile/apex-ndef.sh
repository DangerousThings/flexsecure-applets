#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/apex-ndef/target
cd /app/src/applets/apex-ndef
JC_HOME=/app/sdks/jc305u3_kit ant
cp /app/src/applets/apex-ndef/target/*.cap /app/src/bin/
