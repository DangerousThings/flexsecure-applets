#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/vk-u2f/target
cd /app/src/applets/vk-u2f
JC_HOME=/app/sdks/jc305u3_kit ant
cp /app/src/applets/vk-u2f/target/*.cap /app/src/bin/
