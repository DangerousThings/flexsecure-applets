#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/vk-u2f/target
cd /app/src/applets/vk-u2f
cp /app/src/scripts/compile/res/vk-u2f.build.xml .
JC_HOME=/app/sdks/jc304_kit ant -buildfile vk-u2f.build.xml
cp /app/src/applets/vk-u2f/target/*.cap /app/src/bin/
