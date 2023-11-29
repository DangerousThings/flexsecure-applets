#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/SatochipApplet/target
cd /app/src/applets/SatochipApplet
cp /app/src/scripts/compile/res/SatochipApplet.build.xml .
JC_HOME=/app/sdks/jc304_kit ant -buildfile SatochipApplet.build.xml
cp /app/src/applets/SatochipApplet/target/*.cap /app/src/bin/
