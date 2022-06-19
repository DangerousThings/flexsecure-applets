#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/SmartPGP/target
cd /app/src/applets/SmartPGP
cp /app/src/scripts/compile/res/SmartPGP.build.xml .
JC_HOME=/app/sdks/jc304_kit ant -buildfile SmartPGP.build.xml
cp /app/src/applets/SmartPGP/target/*.cap /app/src/bin/
