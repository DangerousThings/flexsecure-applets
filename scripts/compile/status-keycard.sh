#!/bin/bash

cd /app/src/applets/status-keycard
JC_HOME=/app/sdks/jc304_kit ./gradlew convertJavacard
cp /app/src/applets/status-keycard/build/javacard/im/status/keycard/javacard/*.cap /app/src/bin/
