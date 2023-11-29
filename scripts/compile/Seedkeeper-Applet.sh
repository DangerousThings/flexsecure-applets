#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/Seedkeeper-Applet/target
cd /app/src/applets/Seedkeeper-Applet
cp /app/src/scripts/compile/res/Seedkeeper-Applet.build.xml .
JC_HOME=/app/sdks/jc304_kit ant -buildfile Seedkeeper-Applet.build.xml
cp /app/src/applets/Seedkeeper-Applet/target/*.cap /app/src/bin/
