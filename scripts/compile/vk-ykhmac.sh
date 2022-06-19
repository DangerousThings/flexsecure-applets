#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/vk-ykhmac
ant dist
cp /app/src/applets/vk-ykhmac/target/*.cap /app/src/bin/
cp /usr/bin/yktool.jar /app/src/bin/
