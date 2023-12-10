#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/apex-spark/target
cd /app/src/applets/apex-spark
JC_HOME=/app/sdks/jc305u3_kit ant
cp /app/src/applets/apex-spark/target/*.cap /app/src/bin/
