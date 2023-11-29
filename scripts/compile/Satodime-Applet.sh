#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/Satodime-Applet/target
cd /app/src/applets/Satodime-Applet
cp /app/src/scripts/compile/res/Satodime-Applet.build.xml .
JC_HOME=/app/sdks/jc304_kit ant -buildfile Satodime-Applet.build.xml
cp /app/src/applets/Satodime-Applet/target/*.cap /app/src/bin/
